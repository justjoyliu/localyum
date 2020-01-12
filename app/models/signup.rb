# == Schema Information
#
# Table name: signups
#
#  id                    :integer          not null, primary key
#  hostevent_id          :integer
#  user_id               :integer
#  confirmation_host     :boolean          default(FALSE)
#  confirmation_guest    :boolean          default(FALSE)
#  confirmation_status   :string(255)
#  payment_status        :string(255)      default("Pending")
#  payment_amt           :decimal(12, 2)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  taste_rating          :integer
#  experience_rating     :integer
#  charge_id             :string(255)
#  card_id               :string(255)
#  pay_portal_fee_cents  :integer
#  card_last_4           :integer
#  card_mth              :integer
#  card_yr               :integer
#  pay_failure_msg       :string(255)
#  refund_amt_cent       :integer
#  card_status           :string(255)      default("ok")
#  dispute_flag          :boolean          default(FALSE)
#  host_rating_for_guest :integer
#  permalink             :string(255)
#  guest_count           :integer          default(1)
#  own_group_flag        :boolean          default(FALSE)
#

class Signup < ActiveRecord::Base
  attr_accessible :confirmation_guest, :confirmation_host, :confirmation_status, 
  	:hostevent_id, :payment_amt, :payment_status, :user_id, 
  	:taste_rating, :experience_rating, 
    :guest_count, :own_group_flag
	
  belongs_to :user
  belongs_to :hostevent

  # before_save :make_permalink
  before_create :make_permalink

  validates :guest_count, :inclusion => {:in => 1..6}

  def event_upcoming?
  	return self.hostevent.event_start_date_upcoming?
  end

  def signup_collapse
    # "\"#collapsemenuitem" + item.id.to_s + "\""
    "#collapsesignup" + self.permalink.to_s
  end

  def signup_collapse_inner
    # "\"collapsemenuitem" + item.id.to_s + "\""
    "collapsesignup" + self.permalink.to_s
  end

  def signup_withdraw #in users_controller deactivate_account
    # self.update_attribute(:confirmation_status, "Withdrawn")
    # self.update_attribute(:confirmation_guest, :false)
    self.guest_withdraw(self.hostevent.cancellation_fee_cents * self.guest_count)
  end

  def host_withdraw
    ch_id = self.charge_id
    
    if ch_id.nil?
      self.update_attribute(:confirmation_status, "Withdrawn")   
      self.update_attribute(:confirmation_host, :false)
      self.update_attribute(:payment_status, "Refunded")
      self.update_attribute(:refund_amt_cent, 0)
      return 0
    else
      # Stripe.api_key = "sk_test_sWNbWe3J6bswuVe7Qjl6kuFu"
      Stripe.api_key = "sk_live_fORb3CqCSmxov9LudZx42ziZ"
      ch = Stripe::Charge.retrieve(ch_id)

      if ch.nil?
        self.update_attribute(:confirmation_status, "Withdrawn")   
        self.update_attribute(:confirmation_host, :false)
        self.update_attribute(:payment_status, "Refunded")
        self.update_attribute(:refund_amt_cent, 0)
        return 0
      else
        already_refunded = ch.amount_refunded 
        amt_to_refund = self.payment_amt.to_i - already_refunded

        self.update_attribute(:confirmation_status, "Withdrawn")   
        self.update_attribute(:confirmation_host, :false)
        self.update_attribute(:payment_status, "Refunded")
        self.update_attribute(:refund_amt_cent, self.payment_amt)
        
        if amt_to_refund <= 0
          return 0
        else
          re = ch.refund(:amount => amt_to_refund)  
          return amt_to_refund
        end
      end
    end
  end

  def guest_withdraw(amt_cents)
    ch_id = self.charge_id

      # if self.refund_amt_cent.nil?
      #   total_refunded = amt_cents
      # else
      #   total_refunded = amt_cents + self.refund_amt_cent
      # end

    if ch_id.nil? or self.payment_amt == 0
      self.update_attribute(:confirmation_status, "Withdrawn")   
      self.update_attribute(:confirmation_guest, :false)   
      self.update_attribute(:payment_status, "Refunded")
      UserMailer.signup_guest_withdraw(self, 0, "unpaid").deliver
      return "You have successfully withdrawn from this event. You did not make any contributions for us to refund."
    else
      # Stripe.api_key = "sk_test_sWNbWe3J6bswuVe7Qjl6kuFu"
      Stripe.api_key = "sk_live_fORb3CqCSmxov9LudZx42ziZ"

      ch = Stripe::Charge.retrieve(ch_id)
      
      if ch.nil? 
        self.update_attribute(:confirmation_status, "Withdrawn")   
        self.update_attribute(:confirmation_guest, :false)   
        self.update_attribute(:payment_status, "Refunded")
        UserMailer.signup_guest_withdraw(self, 0, "unpaid").deliver
        return "You have successfully withdrawn from this event. You did not make any contributions for us to refund."
      elsif ch.refunded or ch.amount_refunded >= amt_cents
        self.update_attribute(:confirmation_status, "Withdrawn")   
        self.update_attribute(:confirmation_guest, :false)   
        self.update_attribute(:payment_status, "Refunded")
        self.update_attribute(:refund_amt_cent, ch.amount_refunded.to_i)
        return "You have successfully withdrawn from this event. We have already refunded $" + (ch.amount_refunded.to_f/100.00).round(2).to_s + " in the past, thus we will no longer be able to refund anymore amount according to the cancellation policy of this event."
      else
        re = ch.refund(:amount => amt_cents)
        
        # if !re.nil? and re.amount_refunded.to_i == total_refunded
        if re.nil? 
            return 'Sorry, we encountered an error when processing your withdrawal from this event. Please try again. We appreciate your patience.'
        else
          self.update_attribute(:confirmation_status, "Withdrawn")   
          self.update_attribute(:confirmation_guest, :false)   
          self.update_attribute(:payment_status, "Refunded")   
          self.update_attribute(:refund_amt_cent, re.amount_refunded.to_i)   
          UserMailer.signup_guest_withdraw(self, amt_cents, "paid").deliver
          UserMailer.signup_guest_withdraw_alert_host(self).deliver
          return 'You have successfully withdrawn from this event. We will refund $' + (re.amount_refunded.to_f/100).round(2).to_s + ' of your contribution back onto your credit card according to the cancellation policy within a week.' 
        end
      end
    end
    
  end

  private
    def make_permalink
      self.permalink = loop do
        random_token = SecureRandom.hex(8)
        break random_token unless Signup.where(permalink: random_token).exists?
      end
    end
end
