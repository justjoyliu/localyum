# == Schema Information
#
# Table name: users
#
#  id                         :integer          not null, primary key
#  name                       :string(255)
#  email                      :string(255)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  password_digest            :string(255)
#  remember_token             :string(255)
#  avatar_file_name           :string(255)
#  avatar_content_type        :string(255)
#  avatar_file_size           :integer
#  avatar_updated_at          :datetime
#  admin                      :boolean          default(FALSE)
#  last_name                  :string(255)
#  user_story                 :text
#  link_facebook              :string(255)
#  link_twitter               :string(255)
#  link_pintrest              :string(255)
#  link_foodblog              :string(255)
#  validation_code            :string(255)
#  validation_flag            :boolean
#  password_reset_token       :string(255)
#  password_reset_sent_at     :datetime
#  active_status              :boolean          default(TRUE)
#  account_balance_cents      :integer          default(0)
#  recipient_id               :string(255)
#  permalink                  :string(255)
#  provider                   :string(255)      default("web")
#  fbid                       :integer
#  yummer_flag                :boolean          default(TRUE)
#  host_flag                  :boolean          default(TRUE)
#  chef_flag                  :boolean          default(FALSE)
#  allow_offsite_request_flag :boolean          default(FALSE)
#

class User < ActiveRecord::Base
	
	# tells Rails which attributes of the model are accessible, 
	# iow which attributes can be modified automatically by outside users
  	attr_accessible :name, :last_name, :email, :password, :password_confirmation, 
      :validation_code, :validation_flag,
      :avatar, :user_story, 
      :link_facebook, :link_twitter, :link_pintrest, :link_foodblog, 
      :yummer_flag, :host_flag, :chef_flag, :allow_offsite_request_flag
  	
    has_secure_password
    has_attached_file :avatar, 
      :default_url => 'chefs_hat.png',
      :styles => { :medium => "300x300^", :thumb => "80x80^" },
      :convert_options => { :medium => " -gravity center -crop '300x300+0+0'",
                            :thumb => " -gravity center -crop '80x80+0+0'"
                          },
      :url => "/users/:style/:id/:basename.:extension", 
      :path => ":rails_root/public/users/:style/:id/:basename.:extension"
      # :url => "/assets/users/:style/:id/:basename.:extension", 
      # :path => ":rails_root/public/assets/users/:style/:id/:basename.:extension"
      # :processors => [:thumbnail]
      #:url => ":attachment/:id/:style/:basename.:extension", 
      #:path => ":rails_root/public/:attachment/:id/:style/:basename.:extension"
    
  #added when creating following ability
    has_many :relationships, foreign_key: "follower_id", dependent: :destroy
    #association for an array using the followed_id in the relationships table
    has_many :followed_users, through: :relationships, source: :followed
    has_many :reverse_relationships, foreign_key: "followed_id",
                                   class_name:  "Relationship", #need to includ otherwise Rails would look for a ReverseRelationship class
                                   dependent:   :destroy
    #could actually omit the :source key in this case
    #because Rails will singularize “followers” 
    #and automatically look for the foreign key follower_id 
    has_many :followers, through: :reverse_relationships, source: :follower

  #added when adding events
    has_many :eventactivities, through: :hostevents
    has_many :addressusers, dependent: :destroy
    has_many :menuitems
    has_many :recipereqs
    # has_many :recipereqed, foreign_key: "chef_id"
    # has_many :eventphotos
    has_many :hostevents_as_host, :class_name => "Hostevent"
    has_many :userbalances
    has_many :hostevents_as_chef, :class_name => "Hostevent"

  #added when signing up for events
    has_many :signups
    has_many :hostevents, through: :signups

  #added when adding messaging
    has_many :messages, foreign_key: "sender_id"
    has_many :messages_received, foreign_key: "receiver_id", class_name:  "Message"

  #revenue
    has_many :host_penalties

  has_one :unsubscribe
  has_many :suggestion_inputs
  
  # callback method that makes email all lowercase before saving
	  before_save { |user| user.email = email.downcase }
    before_save :create_remember_token
    before_create :make_permalink

  # validate that the name is present
  	validates :name,  presence: true #, length: { :within => 3..30 }
    #validates :last_name,  presence: true, :on => :create
  	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  	validates :email, presence: true, 
  					format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

    validates :password, length: { minimum: 6 }, :on => :create
  
  #validates_confirmation_of :password
    validates :password_confirmation, presence: true, :on => :create

  #validates photo
    validates_attachment_size :avatar, :less_than=>5.megabyte
    validates_attachment_content_type :avatar, :content_type=>['image/jpeg', 'image/jpg' 'image/png', 'image/gif', 'image/pjpeg'] 

  #validation of basic info
    validates :user_story, :length => { :maximum => 5000 }
    # validates :zipcode, 
    #   :numericality => { :only_integer => true, :message => "please enter valid zip code" }, 
    #   :length => { :is => 5, :message => "please enter valid zip code"}, 
    #   :allow_nil => true, 
    #   :allow_blank => true

  # following
    #takes in a user and checks to see if a followed user with that id 
    #exists in the database
    def following?(other_user)
      relationships.find_by_followed_id(other_user.id)
    end

    #create a following relationship with utility method for user.follow!(other_user)
    #! means exception will be raised on failure
    def follow!(other_user)
      relationships.create!(followed_id: other_user.id)
    end

    def unfollow!(other_user)
      relationships.find_by_followed_id(other_user.id).destroy
    end

  # hostevents
    def upcomingevents_as_host
      # @today_date = Time.new.to_date
      # @today_hour = Time.new.strftime("%H").to_i
      # @today_datetime = DateTime.new(@today_date.year, @today_date.month, @today_date.day, @today_hour)
      return self.hostevents_as_host.where("mealstarttime > ?", Date.today)
    end

    def upcoming_openevents_as_host
      # @today_date = Time.new.to_date
      # @today_hour = Time.new.strftime("%H").to_i
      # @today_datetime = DateTime.new(@today_date.year, @today_date.month, @today_date.day, @today_hour)
      return self.hostevents_as_host.where("mealstarttime > ? and eventstatus = ?", Date.today, "Open")
    end

    def upcomingevents_as_host_pending_action
      # @today_date = Time.new.to_date
      # @today_hour = Time.new.strftime("%H").to_i
      # @today_datetime = DateTime.new(@today_date.year, @today_date.month, @today_date.day, @today_hour)
      
      @upcoming_evts = self.hostevents_as_host.where("mealstarttime > ?", Date.today)

      pending_action = 0 

      @upcoming_evts.each do |e|
        pending_action += e.signups.where("confirmation_status = ? and confirmation_host = ?", "Waiting", "0").count
      end

      return pending_action
    end

    def upcomingevents_as_guest
      # @today_date = Time.new.to_date
      # @today_hour = Time.new.strftime("%H").to_i
      # @today_datetime = DateTime.new(@today_date.year, @today_date.month, @today_date.day, @today_hour)
      return self.hostevents.where("mealstarttime > ?", Date.today)
    end

    def upcomingevents_guest_pending_action
      # @today_date = Time.new.to_date
      # @today_hour = Time.new.strftime("%H").to_i
      # @today_datetime = DateTime.new(@today_date.year, @today_date.month, @today_date.day, @today_hour)
      
      @upcoming_evts = self.hostevents.where("mealstarttime > ? and confirmation_status = ?", Date.today, "Confirmed")

      return @upcoming_evts.count
    end

  # ratings 
    def user_taste_rating
      taste_rating_cnt = 0
      taste_rating_score = 0
      
      @hostevents = self.hostevents_as_host
      
      @hostevents.each do |e|
        e.signups.each do |s|
          unless s.taste_rating.nil?
            taste_rating_cnt += 1
            taste_rating_score += s.taste_rating
          end
        end
      end

      if taste_rating_cnt == 0
        return 0
      else
        return ((taste_rating_score.to_f / taste_rating_cnt * 2).round / 2.0 )
      end   
    end

    def user_experience_rating
      experience_rating_cnt = 0
      experience_rating_score = 0
      
      @hostevents = self.hostevents_as_host
      
      @hostevents.each do |e|
        e.signups.each do |s|
          unless s.experience_rating.nil?
            experience_rating_cnt += 1
            experience_rating_score += s.experience_rating
          end
        end
      end

      if experience_rating_cnt == 0
        return 0
      else
        return ((experience_rating_score.to_f / experience_rating_cnt * 2).round / 2.0 )
      end
    end

    def user_as_guest_rating
      positive = self.signups.where("confirmation_status = 'Attending' and host_rating_for_guest is not null").sum  :host_rating_for_guest
      votes = self.signups.where("confirmation_status = 'Attending' and host_rating_for_guest is not null").count

      if votes > 0
        return (positive.to_f/votes.to_f)
      else
        return -2
      end
    end

  # acct status maintenance
    def send_password_reset
      self.update_attribute(:password_reset_token, SecureRandom.urlsafe_base64)
      self.update_attribute(:password_reset_sent_at, Time.zone.now)
      UserMailer.password_reset(self).deliver
    end

    def name_deactivation_consider
      if self.active_status?
        return self.name
      else
        return self.name + " (de-activated)"
      end
    end

  # acct balance
    def potential_revenue
      # before adding chef requests
      # evts = self.hostevents_as_host.where("eventstatus in ('Open') and mealstarttime between ? and ?", (Date.today - 48.hours), Date.today)
      evts = Hostevent.where("eventstatus in ('Open') and chef_id = ? and mealstarttime between ? and ?", self.id, (Date.today - 48.hours), Date.today)
      revenue = 0 

      evts.each do |e|
        unless e.signups.where("confirmation_status in ('Attending') and dispute_flag = 1").count > 0
          if e.signups.where("confirmation_status in ('Attending', 'Withdrawn')").count > 0 
            if e.host_net_earnings_cents == 0
              revenue += e.event_host_earnings  
            else
              revenue += e.host_net_earnings_cents  
            end 
          end
        end
      end

      return revenue
    end

    def total_revenue
      # before adding chef requests
      # evts = self.hostevents_as_host.where("eventstatus in ('Open') and mealstarttime < ?", (Date.today - 48.hours))
      evts = Hostevent.where("chef_id = ? and eventstatus in ('Open') and mealstarttime < ?", self.id, (Date.today - 48.hours))
      revenue = 0 

      evts.each do |e|
        unless e.signups.where("confirmation_status in ('Attending') and dispute_flag = 1").count > 0
          if e.signups.where("confirmation_status in ('Attending', 'Withdrawn')").count > 0 
            if e.host_net_earnings_cents == 0
              revenue += e.event_host_earnings  
            else
              revenue += e.host_net_earnings_cents  
            end 
          end
        end
      end

      return revenue
    end

    def available_for_payout(failed_transfers_penalty_amt)
      
      # total not paid revenue
        # before adding chef requests
        # evts = self.hostevents_as_host.where("eventstatus in ('Open') and mealstarttime < ? and host_net_earnings_cents > 0 and (payout_status not in ('paid') or payout_status is null)", (Date.today - 48.hours))
        evts = Hostevent.where("chef_id = ? and eventstatus in ('Open') and mealstarttime < ? and host_net_earnings_cents > 0 and (payout_status not in ('paid', 'pending') or payout_status is null)", self.id, (Date.today - 48.hours))
        payout = 0 

        # Stripe.api_key = "sk_test_sWNbWe3J6bswuVe7Qjl6kuFu"
        Stripe.api_key = "sk_live_fORb3CqCSmxov9LudZx42ziZ"

        evts.each do |e|
          unless e.signups.where("confirmation_status in ('Attending') and dispute_flag = 1").count > 0 
            if e.transfer_id.nil?
              payout += e.host_net_earnings_cents
            else
              tr = Stripe::Transfer.retrieve(e.transfer_id)
              e.update_attribute(:payout_status, tr.status)
              unless tr.status == "paid" or tr.status == "pending"
                payout += e.host_net_earnings_cents 
              end
            end
          end
        end

      # total penalties from cancelled events
        penalty_cents = self.host_penalties.sum  :penalty_amount_cents

      if penalty_cents.nil?
        return Hash["penalty_from_cancelled_events" => failed_transfers_penalty_amt, "payout" => payout]
      else
        bal = (payout - penalty_cents - failed_transfers_penalty_amt)
        return Hash[:penalty_from_cancelled_events => penalty_cents, :payout => bal]
      end
    end

    def bank_acct_info
      if self.recipient_id.nil?
        return nil
      else
        # Stripe.api_key = "sk_test_sWNbWe3J6bswuVe7Qjl6kuFu"
        Stripe.api_key = "sk_live_fORb3CqCSmxov9LudZx42ziZ"
        re = Stripe::Recipient.retrieve(self.recipient_id)

        # if re.verified
          return re.active_account
        # else
          # return nil
        # end
      end
    end

  # fb login
    def self.from_omniauth(auth)
      where("fbid = ? or email = ?", auth.uid, auth.info.email).first_or_initialize.tap do |user|
        user.email = auth.info.email
        user.provider = 'facebook'

        user.fbid = auth.uid
        user.name = auth.info.first_name
        user.last_name = auth.info.last_name
        # user.link_facebook = auth.info.urls.Facebook
        user.remember_token = auth.credentials.token 
        user.validation_flag = 1
        if user.avatar_file_name.nil?
          for_image = 'https://graph.facebook.com/' + auth.uid.to_s + '/picture?width=700&height=700'
          # for_image = 'http://graph.facebook.com/' + auth.info.username.to_s + '/picture?width=700&height=700'
          user.avatar = URI.parse(for_image)
        end
        if user.password_digest.nil?
          user.password = auth.uid
          user.password_confirmation = auth.uid
        end
        # user.oauth_expires_at = Time.at(auth.credentials.expires_at)
        user.save!
      end
    end

  private

    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end

    def make_permalink
      self.permalink = loop do
        # random_token = SecureRandom.urlsafe_base64(nil, false)
        random_token = SecureRandom.hex(8)
        break random_token unless User.where(permalink: random_token).exists?
      end
    end  
end
