# == Schema Information
#
# Table name: hostevents
#
#  id                        :integer          not null, primary key
#  startdate                 :date
#  mealstarttime             :datetime
#  price                     :decimal(6, 2)
#  guestallowforprep         :boolean          default(FALSE)
#  timestartprep             :datetime
#  maxguests                 :integer
#  discussiontopics          :text
#  bestwaytocontact          :string(255)
#  extracomments             :text
#  requestsforguests         :text
#  mustbookhoursinadvance    :integer
#  eventstatus               :string(255)      default("Setup")
#  confirmability            :boolean          default(TRUE)
#  user_id                   :integer
#  addressuser_id            :integer
#  eventcategory_id          :integer
#  charitypolicy_id          :integer
#  cancellationpolicy_id     :integer          default(1)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  event_name                :string(255)
#  transfer_id               :string(255)
#  payout_method             :string(255)      default("Check")
#  address_to_send_payout_id :integer
#  payout_status             :string(255)
#  payout_date               :date
#  host_net_earnings_cents   :integer          default(0)
#  host_charity_cents        :integer
#  ly_charity_cents          :integer
#  ly_net_host_fee           :integer
#  payout_non_ach_info       :string(255)
#  penalty_cents             :integer          default(0)
#  clean_optin               :boolean          default(FALSE)
#  local_ingredients_optin   :boolean          default(FALSE)
#  permalink                 :string(255)
#  tip_included              :boolean          default(FALSE)
#  age_21plus                :boolean          default(FALSE)
#  chef_id                   :integer
#  chef_comment              :text
#  chef_confirm              :boolean          default(FALSE)
#

class Hostevent < ActiveRecord::Base
  attr_accessible :startdate, :mealstarttime, :eventcategory_id, 
    :price, :charitypolicy_id, :cancellationpolicy_id,
    :mustbookhoursinadvance, :maxguests, :confirmability, 
    :bestwaytocontact, :discussiontopics, :extracomments, :guestallowforprep, 
  	:requestsforguests, :timestartprep, 
  	:eventstatus, 
  	:addressuser_id,  
    :eventactivity_ids, :menuitem_ids, #:eventphoto_ids
    :event_name, :clean_optin, :local_ingredients_optin, 
    :user_id, :chef_id,
    :age_21plus, :tip_included

  LY_HOST_FEE_RATE = 0.05
  # LY_HOST_FEE_RATE = 0.1
  
  before_create :make_permalink

  # evt details
    belongs_to :charitypolicy
    belongs_to :cancellationpolicy
    belongs_to :addressuser
    belongs_to :eventcategory

    has_and_belongs_to_many :eventactivities, :uniq => true
    has_and_belongs_to_many :menuitems, :uniq => true
    # has_and_belongs_to_many :eventphotos, :uniq => true
    has_many :eventphotos #, :accessible => true
    accepts_nested_attributes_for :eventphotos

    has_many :host_penalties
    
  # evt signups
    has_many :signups
    has_many :users, :through => :signups
    belongs_to :host, :class_name => "User", :foreign_key => :user_id

  # evt messages
    has_many :messagechains
    has_many :messages, :through => :messagechains

  # evt requests
    belongs_to :recipereq
    belongs_to :chef, :class_name => "User", :foreign_key => :chef_id

  # validations
    validates :user_id, presence: true
    validates :event_name, presence: true #, :uniqueness => {:scope => :startdate}
    validates :confirmability, presence: true
    validates :mealstarttime, presence: true
    validates_date :startdate, presence: true, :on_or_after => lambda { Date.current }
    validates :price, presence: true
    # validates_inclusion_of :price, presence: true,  :in => 1..999
    #validates :price, presence: true, :numericality => {:greater_than => 0, :less_than => 10}

    validates :eventcategory_id, presence: true
    validates :cancellationpolicy_id, presence: true

    # validates_uniqueness_of :event_name, :scope => [:startdate]

    validates_length_of :event_name, :maximum => 60, :allow_blank => true

  def eventphoto_attributes=(eventphoto_attributes)
    eventphoto_attributes.each do |attributes|
      eventphotos.build(attributes)
    end
  end

  def hostevent_user(hostevent)
    User.find(hostevent.user_id)
  end

  def chef_user
    if self.chef_id.empty?
      return User.find(self.user_id)
    else
      return User.find(self.chef_id)
    end
  end

  # event set up
    def hostevent_step1?
      if self.menuitems.count > 0
        return true
      else 
        return false 
      end
    end

    def hostevent_step2?
      @address = Addressuser.find_by_id(self.addressuser_id)

      if self.addressuser_id.blank? || self.bestwaytocontact.blank? || self.event_name.blank?
        return false
      elsif @address.nil? || @address.line1.nil?
          return false
      else 
        return true 
      end
    end

    def hostevent_step3?
      # uncomment if need event photo before open event
      if self.eventphotos.count > 0
        return true
      else
        return false 
      end
    end

    def hostevent_status_could_be_complete?
      if self.hostevent_step1? && self.hostevent_step2? #&& self.hostevent_step3?
        return true
      else
        return false
      end
    end

    def hostevent_to_complete
      tocompletestep = 0
      if self.menuitems.count == 0
        tocompletestep += 1
      end

      @address = Addressuser.find_by_id(self.addressuser_id)

      if self.addressuser_id.blank? || @address.nil? || @address.line1.nil?
        tocompletestep += 1
      end
      if self.bestwaytocontact.blank?
        tocompletestep += 1
      end
      if self.event_name.blank?
        tocompletestep += 1
      end

      # if self.eventphotos.count == 0
      #   tocompletestep += 1
      # end

      return tocompletestep
    end

    def evt_open?
      if self.eventstatus != 'Open'
        return false
      elsif self.chef_id == self.user_id 
        return true
      elsif self.chef_confirm?
        return true
      else
        return false
      end
    end

  # event menu details
    def event_all_activity
      self.menuitems.find_all_by_course("Activity")
    end

    def event_all_appetizers
      self.menuitems.find_all_by_course("Appetizer")
    end

    def event_all_soups
      self.menuitems.find_all_by_course("Soup")
    end

    def event_all_mains
      self.menuitems.find_all_by_course("Main")
    end

    def event_all_salads
      self.menuitems.find_all_by_course("Salad")
    end

    def event_all_cheeses
      self.menuitems.find_all_by_course("Cheese")
    end

    def event_all_sides
      self.menuitems.find_all_by_course("Side")
    end

    def event_all_desserts
      self.menuitems.find_all_by_course("Dessert")
    end

    def event_all_wines
      self.menuitems.find_all_by_course("Wine")
    end

  # event sign up 
    def event_start_date_upcoming?
      # @today_date = Time.new.to_date
      # @today_hour = Time.new.strftime("%H").to_i
      # @today_datetime = DateTime.new(@today_date.year, @today_date.month, @today_date.day, @today_hour)
      # if self.mealstarttime >= @today_datetime 
      if self.startdate >= Date.today
        return true
      end

      return false
    end

    def exceed_max_guests?(trytosignup=1)
      if self.maxguests.blank?
        return false  
      end

      @req_and_come = self.signups.where('confirmation_status = ? or confirmation_status = ? or confirmation_status = ?', 'Attending', 'Confirmed', 'Waiting')
      if @req_and_come.nil?
        req_and_come_cnt = 0
      else  
        req_and_come_cnt = @req_and_come.sum(:guest_count)
      end
      # signedup = trytosignup + (self.signups.find_all_by_confirmation_status("Attending").count + self.signups.find_all_by_confirmation_status("Confirmed").count + self.signups.find_all_by_confirmation_status("Waiting").count)
      # signedup = (trytosignup + self.signups.find_all_by_confirmation_status("Attending").sum(:guest_count) + self.signups.find_all_by_confirmation_status("Confirmed").sum(:guest_count) + self.signups.find_all_by_confirmation_status("Waiting").sum(:guest_count))
      signedup = (trytosignup + req_and_come_cnt)

      if signedup > self.maxguests 
        return true
      else
        return false
      end
    end

    def past_mustbook_time?
      if self.mustbookhoursinadvance.blank? or self.mustbookhoursinadvance.to_i == 0
        # @today_date = (Time.new).to_date
        # @today_hour = (Time.new).strftime("%H").to_i
        if self.startdate < Date.today
          return true
        end

        return false
      else
        @today_date = (Time.new + (self.mustbookhoursinadvance * 60*60)).to_date
        @today_hour = (Time.new + (self.mustbookhoursinadvance * 60*60)).strftime("%H").to_i
        @mustbook_datetime = DateTime.new(@today_date.year, @today_date.month, @today_date.day, @today_hour)
        if self.mealstarttime > @mustbook_datetime 
          return false
        end
        return true
      end
    end

  # event ratings
    def event_taste_rating_text
      taste_rating_cnt = 0
      taste_rating_score = 0
      
      self.signups.each do |s|
        if !s.taste_rating.nil?
          taste_rating_cnt += 1
          taste_rating_score += s.taste_rating
        end
      end

      if taste_rating_cnt == 0
        return "no ratings"
      else
        return ((taste_rating_score.to_f / taste_rating_cnt * 2).round / 2.0 ).to_s + " (" + taste_rating_cnt.to_s + ")"
      end
      
    end

    def event_taste_rating
      taste_rating_cnt = 0
      taste_rating_score = 0
      
      self.signups.each do |s|
        if !s.taste_rating.nil?
          taste_rating_cnt += 1
          taste_rating_score += s.taste_rating
        end
      end

      if taste_rating_cnt == 0
        return 0
      else
        return ((taste_rating_score.to_f / taste_rating_cnt * 2).round / 2.0 )
      end
      
    end

    def event_experience_rating_text
      experience_rating_cnt = 0
      experience_rating_score = 0

      self.signups.each do |s|
        if !s.experience_rating.nil?
          experience_rating_cnt += 1
          experience_rating_score += s.experience_rating
        end
      end

      if experience_rating_cnt == 0
        return "no ratings"
      else
        return ((experience_rating_score.to_f / experience_rating_cnt * 2).round / 2.0 ).to_s + " (" + experience_rating_cnt.to_s + ")"
      end
    end

    def event_experience_rating
      experience_rating_cnt = 0
      experience_rating_score = 0

      self.signups.each do |s|
        if !s.experience_rating.nil?
          experience_rating_cnt += 1
          experience_rating_score += s.experience_rating
        end
      end

      if experience_rating_cnt == 0
        return 0
      else
        return ((experience_rating_score.to_f / experience_rating_cnt * 2).round / 2.0 )
      end
    end

  # event revenue
    def guests_attending
      return self.signups.where("confirmation_status = ?", "Attending")
    end

    def event_attend_count
      return self.signups.where("confirmation_status = ? and payment_status in (?, ?)", "Attending", "Captured", "NA").sum(:guest_count)
      # .count
    end

    def event_revenue_signup_count
      # Stripe.api_key = "sk_test_sWNbWe3J6bswuVe7Qjl6kuFu"
      Stripe.api_key = "sk_live_fORb3CqCSmxov9LudZx42ziZ"
      charge_collected = 0
      # attended = self.signups.where("confirmation_status = ? and payment_status = ?", "Attending", "Captured")
      attended = self.signups.find_all_by_confirmation_status("Attending")

      attended.each do |s|
        unless s.charge_id.nil?
          ch = Stripe::Charge.retrieve(s.charge_id)
          if ch.captured and !ch.refunded and (ch.amount.to_i >= (self.price * 100).to_i) and ch.dispute.nil?
              charge_collected +=  s.guest_count
              # 1
          end
        end
      end

      return charge_collected
    end

    def event_revenue_guest_withdrawn_cents
      # Stripe.api_key = "sk_test_sWNbWe3J6bswuVe7Qjl6kuFu"
      Stripe.api_key = "sk_live_fORb3CqCSmxov9LudZx42ziZ"
      not_refunded_revenue_cents = 0
      guest_withdrawn = self.signups.where("confirmation_status = ? and confirmation_guest = 0 and confirmation_host = 1", "Withdrawn")

      guest_withdrawn.each do |s|
        unless s.charge_id.nil?
          ch = Stripe::Charge.retrieve(s.charge_id)
          if ch.captured and ch.dispute.nil?
            net_charge = (self.price * 100 * s.guest_count) - ch.amount_refunded
            if net_charge > 0
              not_refunded_revenue_cents += net_charge
            end
          end
        end
      end

      return not_refunded_revenue_cents
    end

    def event_guest_servicing_fee
      if self.price == 0
        return 0
      elsif self.price <= 20
        return 1
      else
        return (self.price * 0.07).ceil * 0.50
      end
      # elsif self.price <= 20
      #   return 2
      # else
      #   return (self.price * 0.05).ceil
      # end
    end

    def event_guest_price_cents
      if self.price == 0
        return 0
      elsif self.price <= 20
        return ((1 + self.price)*100).to_i
      else
        return (((self.price * 0.07).ceil * 50) + (self.price * 100)).to_i
      end
      # elsif self.price <= 20
      #   return ((2 + self.price)*100).to_i
      # else
      #   return (((self.price * 0.05).ceil + self.price)*100).to_i
      # end
    end

    def cancellation_fee_cents
      @today_date = Time.new.to_date
      @today_hour = Time.new.strftime("%H").to_i
      @today_min = Time.new.strftime("%M").to_i
      @today_datetime = DateTime.new(@today_date.year, @today_date.month, @today_date.day, @today_hour, @today_min)
      
      hrs_until_evt = ((self.mealstarttime - @today_datetime)/ 1.hour).ceil
      policy = self.cancellationpolicy

      if  hrs_until_evt >= policy.hrs_before_1
        return (self.price * 100).to_i
      elsif hrs_until_evt >= policy.hrs_before_2
        return (self.price * policy.refund_percent_2).to_i
      else
        return 0
      end
    end

    # def event_host_fee
      #   evt_revenue_cents = self.price * 100 * self.event_revenue_signup_count
      #   localyum_cut_cents = evt_revenue_cents * ly_host_fee_rate
      #   localyum_charity = self.ly_charity_cents_calc
      #   fee = (localyum_cut_cents - localyum_charity)
        
      #   if self.ly_net_host_fee.nil? or self.ly_net_host_fee != fee
      #     self.update_attribute(:ly_net_host_fee, fee) 
      #   end

      #   if self.ly_charity_cents.nil? or self.ly_charity_cents != localyum_charity
      #     self.update_attribute(:ly_charity_cents, localyum_charity) 
      #   end

      #   return fee
      # end

    def ly_charity_cents_calc(num_attended)
      if self.charitypolicy_id.nil?
        return 0
      else
        evt_revenue_cents = self.price * 100 * num_attended
        localyum_cut_cents = evt_revenue_cents * LY_HOST_FEE_RATE
        return  (localyum_cut_cents * (self.charitypolicy.percentcontribute.to_f/100)).floor
      end
    end

    def host_charity_cents_calc(num_attended)
      if self.charitypolicy_id.nil?
        return 0
      else
        evt_revenue_cents = self.price * 100 * num_attended
        ly_fee_cents = evt_revenue_cents * LY_HOST_FEE_RATE
        # if self.ly_net_host_fee.nil? 
        #   ly_fee = self.event_host_fee + self.ly_charity_cents
        # else
        #   ly_fee = self.ly_net_host_fee + self.ly_charity_cents
        # end

        return  ((evt_revenue_cents - ly_fee_cents) * (self.charitypolicy.percentcontribute.to_f/100)).floor
      end
    end

    def event_host_earnings
      paid_in_full_cnt = self.event_revenue_signup_count

      evt_revenue_cents = (self.price * 100 * paid_in_full_cnt) + self.event_revenue_guest_withdrawn_cents
      evt_host_charity = self.host_charity_cents_calc(paid_in_full_cnt)

      # calc local yum host fees
        localyum_cut_cents = evt_revenue_cents * LY_HOST_FEE_RATE
        localyum_charity = self.ly_charity_cents_calc(paid_in_full_cnt)
        ly_revenue = (localyum_cut_cents - localyum_charity)
        
        if self.ly_net_host_fee.nil? or self.ly_net_host_fee != ly_revenue
          self.update_attribute(:ly_net_host_fee, ly_revenue) 
        end

        if self.ly_charity_cents.nil? or self.ly_charity_cents != localyum_charity
          self.update_attribute(:ly_charity_cents, localyum_charity) 
        end

      net_earnings = (evt_revenue_cents - evt_host_charity - ly_revenue - localyum_charity)

      if self.host_net_earnings_cents.nil? or self.host_net_earnings_cents != net_earnings
        self.update_attribute(:host_net_earnings_cents, net_earnings) 
      end

      if self.ly_net_host_fee.nil? or self.ly_net_host_fee != evt_host_charity
        self.update_attribute(:host_charity_cents, evt_host_charity) 
      end

      return net_earnings
    end

    def event_charity_contributions
      
      # if self.host_charity_cents.nil?
      #   earnings = self.event_host_earnings
      # end

      if self.ly_charity_cents.nil?
        ly = 0
      else
        ly = self.ly_charity_cents
      end

      if self.host_charity_cents.nil?
        h = 0
      else
        h = self.host_charity_cents
      end
      donation = ly + h
      return donation    
    end

    def hostevent_cancellation 
      #used in hostevents_controller hostevent_cancel
      self.update_attribute(:eventstatus, "Cancelled")
      self.update_attribute(:chef_confirm, 0)

      signup_refunded = 0 
      refunded_amount = 0
      paid_guests = self.signups.where("confirmation_host = 1 and confirmation_guest = 1")
      
      paid_guests.each do |s|
        refunded = s.host_withdraw
        if refunded > 0
          # signup_refunded += 1
          signup_refunded += s.guest_count
          refunded_amount += refunded
        end
        UserMailer.host_cancel_event_notify_guest(s, refunded).deliver
      end

      penalty = (signup_refunded * 100) + (refunded_amount * 0.1)
      # if penalty > 0 
        p_record = self.host_penalties.build(:user_id => self.user_id, :number_guests => signup_refunded, :amt_refunded_cents => refunded_amount, :penalty_amount_cents => penalty)
        p_record.save
      # end
    end
    
    def hostevent_reopen
      #used in hostevents_controller hostevent_open
      self.update_attribute(:eventstatus, "Open")
      signuped_guests = self.signups

      unless signuped_guests.empty?
        signuped_guests.each do |s|
          s.update_attribute(:confirmation_host, :true)
          s.update_attribute(:confirmation_status, "Waiting")
        end
      end
      
    end

  def self.search_index(search_param, search_criteria)
    if search_criteria == "N"
      self
    elsif search_criteria == "0" && search_param == "charitypolicy_id"
      @hostevents = self.where("charitypolicy_id is not null")
    elsif search_param == "eventcategory_id"
      @hostevents = self.where("eventcategory_id = ?", search_criteria)
      # where('name LIKE ?', "%#{search}%")
    elsif search_param == "charitypolicy_id"
      @hostevents = self.where("charitypolicy_id = ?", search_criteria)
    end
  end

  private

    def make_permalink
      self.permalink = loop do
        # random_token = SecureRandom.urlsafe_base64(nil, false)
        random_token = SecureRandom.hex(8)
        break random_token unless Hostevent.where(permalink: random_token).exists?
      end
    end  
end
