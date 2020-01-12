
class SignupsController < ApplicationController

  before_filter :signed_in_user, only: [:create, :update, :show, :pay_for_seat, :dispute_event, :host_rate_guest]
  before_filter :active_user, only: [:create, :update, :show, :pay_for_seat, :dispute_event, :host_rate_guest]
  before_filter :correct_user, only: [:show]

  
  def create

    @hostevent = Hostevent.find_by_permalink(params[:permalink])
    signup_hash = params[:signup].merge(:hostevent_id => @hostevent.id, :user_id => current_user.id)

    @signup_history = Signup.where("user_id = ? AND hostevent_id = ?", current_user.id, @hostevent.id)

    if current_user.id == @hostevent.user_id
      flash[:warning] = "Sorry, you cannot sign up for your own event."
      redirect_to hostevent_path(@hostevent.permalink)
    elsif params[:signup][:guest_count].to_i < 4 and params[:signup][:own_group_flag] == '1'
      flash[:error] = 'In order to secure a table for your own group, you must secure four or more seats at the same time.'
      redirect_to hostevent_path(@hostevent.permalink)
    elsif @hostevent.exceed_max_guests?(params[:signup][:guest_count].to_i)
      signup_hash['confirmation_status'] = "Waitlist"
      @signup = Signup.new(signup_hash)
      if @signup.save
        flash[:success] = "You have been successfully added to the waitlist because the event has sold out. We will contact you via email if the host confirms your seat. You can also follow the chef for future event notifications."
      else
        flash[:error] = "Sorry, we've encountered an error when adding you onto the waitlist. Please try again."
      end
      redirect_to hostevent_path(@hostevent.permalink)
    elsif @hostevent.past_mustbook_time?
      flash[:warning] = "The event sign up time has passed. You can no longer sign up for this event. You can follow the chef for future event notifications."
      redirect_to hostevent_path(@hostevent.permalink)
    elsif !@hostevent.event_start_date_upcoming?
      flash[:warning] = "The event has passed. You can no longer sign up."
      redirect_to hostevent_path(@hostevent.permalink)
    elsif @signup_history.empty?
      @signup = Signup.new(signup_hash)
      if @signup.save
        if @signup.confirmation_status == "Confirmed" and @hostevent.price == 0
          @signup.update_attributes(params[:signup]) 
          @signup.update_attributes(:confirmation_status => 'Attending', :payment_status => 'NA', :payment_amt => 0  ) 
          # UserMailer.sign_up_confirm_alert(@signup).deliver
          UserMailer.sign_up_payment_receipt(@signup, 0).deliver
          UserMailer.sign_up_attending_alert(@hostevent).deliver
          flash[:success] = "Welcome to the event! Be social and share it on Facebook or Twitter! (also, be sure to keep your profile picture up to date so the host can recognize you at the event)"
          redirect_to hostevent_path(@hostevent.permalink)
        elsif @signup.confirmation_status == "Confirmed"
          # flash[:success] = "Welcome to " + hostevent.host.name + "'s table. Please confirm your seat request and contribute the chef's requested amount via a credit card to complete sign up."
          flash[:success] = "Welcome to " + @hostevent.host.name + "'s table. Please contribute the requested amount via a credit card to complete sign up."
          redirect_to signup_path(@signup.permalink)
        else
          UserMailer.signed_up_alert(@hostevent).deliver
          flash[:success] = "Thanks for the request! We will contact you once the chef has confirmed your seat (or keep an eye on your upcoming events dashboard). Once confirmed, you will need to provide your contribution via credit card to complete your sign up."
          redirect_to hostevent_path(@hostevent.permalink)
        end   
      else
        flash[:error] = "Sorry, we've encountered an error"
        redirect_to hostevent_path(@hostevent.permalink)
      end
    else
      flash[:success] = "You have already signed up for this event."  
      # redirect_to show_myevents_path
      redirect_to hostevent_path(@hostevent.permalink)
    end
  end

  def update
    # PUT /signups/1
    # PUT /signups/1.json
    # @signup = Signup.find(params[:id])
    @signup = Signup.find_by_permalink(params[:permalink])
    @hostevent = @signup.hostevent

    if params[:signup].has_key?(:confirmation_status) 
      if current_user.id == @hostevent.user_id #host of event
        if params[:signup][:confirmation_status] == "Declined" 
          @signup.update_attributes(params[:signup]) 
          redirect_to signup_requests_path(@hostevent.permalink)
        elsif params[:signup][:confirmation_status] == "Confirmed"
          if @hostevent.price == 0
            @signup.update_attributes(params[:signup]) 
            @signup.update_attributes( :confirmation_status => 'Attending', :payment_status => 'NA', :payment_amt => 0  ) 
            UserMailer.sign_up_payment_receipt(@signup, 0).deliver
            UserMailer.sign_up_attending_alert(@hostevent).deliver
          else
            @signup.update_attributes(params[:signup]) 
            UserMailer.sign_up_confirm_alert(@signup).deliver
          end 
          redirect_to signup_requests_path(@hostevent.permalink)
        elsif params[:signup][:confirmation_status] == "Withdrawn"
          # if @signup.host_withdraw?
          #   flash[:warning] = 'You have successfully declined the request and refunded the contribution this user made.'
          #   redirect_to signup_requests_path(@hostevent.permalink)
          # else
          #   flash[:error] = 'Sorry, we encountered an error when declining this request. Please try again. We appreciate your patience.'
          #   redirect_to signup_requests_path(@hostevent.permalink)
          # end
          flash[:error] = 'You cannot withdraw from this seat since you are the host for this event. You can only decline this seat request.'
          redirect_to signup_requests_path(@hostevent.permalink)
        else
          flash[:error] = 'Sorry, but only the signed up user can perform this action.'
          redirect_to signup_requests_path(@hostevent.permalink)
        end
      elsif current_user.id == @signup.user_id
        if (params[:signup][:confirmation_status] == "Waiting" or params[:signup][:confirmation_status] == "Confirmed" or params[:signup][:confirmation_status] == "Waitlist") 
          if params[:signup][:guest_count].to_i < 4 and params[:signup][:own_group_flag] == '1'
            flash[:error] = 'In order to get a table for your own group, you must take a seat for four or more guests at the same time.'
            redirect_to hostevent_path(@hostevent.permalink)
          elsif @hostevent.exceed_max_guests?(params[:signup][:guest_count].to_i)
            # flash[:warning] = "This event has reached its maximum guest allowed. You can no longer sign up at this time. You can follow the chef for future event notifications."
            @signup.update_attributes(params[:signup])
            @signup.update_attribute(:refund_amt_cent, 0) 
            @signup.update_attribute(:payment_status, "Pending")  
            @signup.update_attribute(:payment_amt, 0)
            @signup.update_attribute(:confirmation_status, "Waitlist")
            flash[:success] = "You have been successfully added to the waitlist because the event has sold out. We will contact you via email if the host confirms your seat. You can also follow the chef for future event notifications."
            redirect_to hostevent_path(@hostevent.permalink)
          elsif @hostevent.past_mustbook_time?
            flash[:warning] = "The event sign up time has passed. You can no longer sign up for this event. You can follow the chef for future event notifications."
            redirect_to hostevent_path(@hostevent.permalink)
          elsif !@hostevent.event_start_date_upcoming?
            flash[:warning] = "The event has passed. You can no longer sign up."
            redirect_to hostevent_path(@hostevent.permalink)
          elsif @hostevent.price == 0
            if @signup.update_attributes(params[:signup]) 
              @signup.update_attributes(:confirmation_status => 'Attending', :payment_status => 'NA', :payment_amt => 0 )
              UserMailer.sign_up_payment_receipt(@signup, 0).deliver
              UserMailer.sign_up_attending_alert(@hostevent).deliver
              flash[:success] = "Welcome to the event! Be social and share it on Facebook or Twitter! (also, be sure to keep your profile picture up to date so the host can recognize you at the event)"
            else
              flash[:error] = 'An error has occured during sign up. Please try again'
            end
            redirect_to hostevent_path(@hostevent.permalink)
          else
            @signup.update_attributes(params[:signup])
            @signup.update_attribute(:refund_amt_cent, 0) 
            @signup.update_attribute(:payment_status, "Pending")  
            @signup.update_attribute(:payment_amt, 0)
            if @signup.confirmation_status == "Confirmed"
              flash[:success] = "Welcome to " + @hostevent.host.name + "'s table. Please confirm your seat request and contribute the chef's requested amount via a credit card to complete sign up."
              redirect_to signup_path(@signup.permalink)
            else
              flash[:success] = "Thanks for the request! We will contact you once the chef has confirmed your seat (or keep an eye on your upcoming events dashboard). Once confirmed, you will need to provide your contribution via credit card to complete your sign up."
              UserMailer.signed_up_alert(@hostevent).deliver
              redirect_to hostevent_path(@hostevent.permalink)
            end  
          end
        elsif params[:signup][:confirmation_status] == "Withdrawn"

          refund_cents = @hostevent.cancellation_fee_cents * @signup.guest_count

          if @signup.confirmation_status == "Withdrawn"
            flash[:warning] = 'You have already withdrawn from this event.'
            redirect_to hostevent_path(@hostevent.permalink)
          elsif @hostevent.price == 0
            @signup.update_attributes( :confirmation_guest => false, :confirmation_status => 'Withdrawn') 
            flash[:warning] = 'You have successfully withdraw from this event.'
            redirect_to hostevent_path(@hostevent.permalink)
          elsif refund_cents == 0
            flash[:error] = 'Sorry, but the cancellation cut off time set by the host has passed. We can no longer refund your contribution.'
            redirect_to hostevent_path(@hostevent.permalink)
          else
            msg = @signup.guest_withdraw(refund_cents)
            # flash[:warning] = 'You have successfully withdrawn from this event. We will refund you the contribution back onto your credit card according to the cancellation policy within a week.'
            flash[:warning] = msg
            redirect_to hostevent_path(@hostevent.permalink)
          end
          
          # @signup.update_attributes(params[:signup]) 
          # redirect_to hostevent_path(@hostevent.permalink)
        elsif params[:signup][:confirmation_status] == "Attending"
          if !@signup.charge_id.nil? 
            # Stripe.api_key = "sk_test_sWNbWe3J6bswuVe7Qjl6kuFu"
            Stripe.api_key = "sk_live_fORb3CqCSmxov9LudZx42ziZ"
            charge = Stripe::Charge.retrieve("ch_25IitbMXDko0rG")
            
            if charge.paid and !charge.refunded
              @signup.update_attributes(params[:signup]) 
              flash[:success] = 'Thank you for confirming your seat. You are all set to go. All that is left is enjoying the event'
              redirect_to hostevent_path(@hostevent.permalink)
            else
              flash[:error] = 'Thanks for choosing to attend. We have not received your contribution yet and cannot confirm your seat. If you have indeed made a payment, please contact us to further investigate. Else, please contribute the requested amount to complete this request.'
              redirect_to signup_path(@signup.permalink)
            end
          else
            # flash[:success] = 'Thank you for choosing to confirm your seat. Please contribute the requested amount to complete this request.'
            flash[:error] = 'Thanks for choosing to attend. We have not received your contribution yet and cannot confirm your seat. If you have indeed made a payment, please contact us to further investigate. Else, please contribute the requested amount to complete this request.'
            redirect_to signup_path(@signup.permalink)
          end 
        end
      else
        flash[:error] = 'You must be signed up for this event to complete this action.'
        redirect_to hostevent_path(@hostevent.permalink) 
      end 
    elsif params[:signup].has_key?(:taste_rating) || params[:signup].has_key?(:experience_rating)
      if @signup.confirmation_status == "Attending"
        @signup.update_attributes(params[:signup]) 
      else
        flash[:errors] = 'You can only rate events that you have contributed to and attended'
      end
      # redirect_to show_mypastevents_path(current_user)
      redirect_to hostevent_path(@hostevent.permalink)
    end

    # respond_to do |format|
      #   if @signup.update_attributes(params[:signup])
      #     format.html { redirect_to signup_path(@signup.permalink), notice: 'Signup was successfully updated.' }
      #     format.json { head :no_content }
      #   else
      #     format.html { render action: "edit" }
      #     format.json { render json: @signup.errors, status: :unprocessable_entity }
      #   end
      # end
  end
  
  def show
      # GET /signups/1
      # GET /signups/1.json
      
      # redirect_to signup_requests_path(@signup.hostevent)
      # respond_to do |format|
      #   format.html # show.html.erb
      #   format.json { render json: @signup }
      # end

      # @signup = Signup.find(params[:id])
      @evt = @signup.hostevent

      if @evt.eventstatus != 'Open'
        flash[:error] = 'Sorry, but the chef has not opened the event yet. Please wait until the event is opened up again in order to pay and secure your seat.'
        redirect_to hostevent_path(@evt.permalink)
      end

      if @signup.payment_status == "Captured" and @signup.confirmation_status == "Attending"
        flash[:warning] = 'You have paid for this event already and your seat is already reserved. Enjoying the event is all that is left to do!'
        redirect_to hostevent_path(@evt.permalink)
      elsif @signup.confirmation_status != "Confirmed" 
        flash[:error] = 'You must have a seat confirmed by the chef in order to pay for the seat.'
        redirect_to hostevent_path(@evt.permalink)
      else
        @evt_price = @evt.event_guest_price_cents * @signup.guest_count
        @cards = Hash.new

        # Stripe.api_key = "sk_test_sWNbWe3J6bswuVe7Qjl6kuFu"
        Stripe.api_key = "sk_live_fORb3CqCSmxov9LudZx42ziZ"
        @signup_cards = current_user.signups.where("card_id is not null and card_status = 'ok' ").select("card_id, card_last_4, card_mth, card_yr").group("card_last_4, card_mth, card_yr")

        @signup_cards.each do |c|
          stripe_card = Stripe::Customer.retrieve(c.card_id)
          # if stripe_card.nil? or stripe_card.delinquent or stripe_card.active_card.cvc_check != "pass" or stripe_card.active_card.address_line1_check != "pass" or stripe_card.active_card.address_zip_check != "pass" 
          if stripe_card.nil? or stripe_card.delinquent or stripe_card.cards.data[0].cvc_check != "pass" or stripe_card.cards.data[0].address_line1_check != "pass" or stripe_card.cards.data[0].address_zip_check != "pass" 
            c.update_attribute(:card_status, "invalid") 
          else
            @cards.merge!(stripe_card.id => { :last4 => stripe_card.cards.data[0].last4, :association => stripe_card.cards.data[0].type.gsub(/\s/, ''), :exp_month => stripe_card.cards.data[0].exp_month, :exp_year => stripe_card.cards.data[0].exp_year })
            # @cards.merge(stripe_card.id => stripe_card.active_card.last4)
          end          
        end
      end
  end 

  def pay_for_seat 
    @signup = Signup.find_by_permalink(params[:permalink])
    @event = Hostevent.find_by_id(@signup.hostevent_id)

    if @signup.payment_status == "Captured" and @signup.confirmation_status == "Attending"
        flash[:warning] = 'You have paid for this event already and your seat is already reserved. Enjoying the event is all that is left to do!'
        redirect_to hostevent_path(@event.permalink)
    elsif @signup.user_id != current_user.id or @signup.confirmation_status != "Confirmed" 
      flash[:error] = 'You must have a seat confirmed by the chef in order to pay for the seat.'
      redirect_to hostevent_path(@event.permalink)
    elsif params.has_key?(:saved_card_id) 
      @user_confirmation = current_user.signups.find_by_card_id(params[:saved_card_id])

      if @user_confirmation.nil? or @user_confirmation.user_id != current_user.id
        flash[:error] = 'You are not the owner of this credit card. Thus you cannot pay with this card. If you still see it as an option to pay, we are very embarrassed. Please contact us ASAP so that we can fix this error.'
        redirect_to signup_path(@signup.permalink)
      else
        # charge existing card (https://stripe.com/docs/tutorials/charges)
        # Stripe.api_key = "sk_test_sWNbWe3J6bswuVe7Qjl6kuFu"
        Stripe.api_key = "sk_live_fORb3CqCSmxov9LudZx42ziZ"
        amt = @event.event_guest_price_cents * @signup.guest_count
        # desc = @event.event_name.truncate(15)
        desc = User.find(@signup.user_id).email + ', user ' + @signup.user_id.to_s + ', event ' + @signup.hostevent_id.to_s + ', for ' + @signup.guest_count.to_s + ' guests'
        
        charge = Stripe::Charge.create(
            :amount => amt, # in cents
            :currency => "usd",
            :customer => params[:saved_card_id],
            :description => desc
        )

        if charge.nil?
          flash[:error] = "Sorry, we encountered an error when processing the card. Please try again."
          redirect_to signup_path(@signup.permalink)
        else
          @signup.update_attribute(:card_id, params[:saved_card_id])
          @signup.update_attribute(:charge_id, charge.id)
          # @signup.update_attribute(:pay_portal_fee_cents, charge.fee)
          @signup.update_attribute(:card_last_4, charge.card.last4)
          @signup.update_attribute(:card_mth, charge.card.exp_month)
          @signup.update_attribute(:card_yr, charge.card.exp_year)
          @signup.update_attribute(:pay_failure_msg, charge.failure_message)

          if charge.captured
            @signup.update_attribute(:payment_status, 'Captured')
            @signup.update_attribute(:payment_amt, charge.amount)
            @signup.update_attribute(:confirmation_status, "Attending")
            UserMailer.sign_up_attending_alert(@event).deliver
            UserMailer.sign_up_payment_receipt(@signup, charge.amount).deliver
            flash[:success] = "Thank you for contributing to the event. Your seat is now reserved. Hope you enjoy the event!"
            redirect_to hostevent_path(@event.permalink)
          elsif charge.paid
            @signup.update_attribute(:payment_status, 'Pending')
            @signup.update_attribute(:payment_amt, charge.amount)
            @signup.update_attribute(:confirmation_status, "Attending")
            UserMailer.sign_up_attending_alert(@event).deliver
            UserMailer.sign_up_payment_receipt(@signup, charge.amount).deliver
            flash[:success] = "Thank you for contributing to the event. Your seat is now reserved. Hope you enjoy the event!"
            redirect_to hostevent_path(@event.permalink)
          else
            @signup.update_attribute(:payment_status, 'Failed')
            UserMailer.signup_error_payment_guest(@signup, charge.failure_message).deliver
            flash[:error] = "We've encountered the error: " + charge.failure_message
            redirect_to signup_path(@signup.permalink)
          end
        end        
      end
    elsif params[:cardholder].empty? or params[:address_zip].empty? or params[:address_line1].empty?
      flash[:error] = 'Please fill in all the information before we can securely process your contribution.'
      redirect_to signup_path(@signup.permalink) 
    else
      # Stripe.api_key = "sk_test_sWNbWe3J6bswuVe7Qjl6kuFu" 
      Stripe.api_key = "sk_live_fORb3CqCSmxov9LudZx42ziZ"

      # Get the credit card details submitted by the form
      token = params[:stripeToken]
      amt = @event.event_guest_price_cents * @signup.guest_count
      # desc = @event.event_name.truncate(15)
      desc = User.find(@signup.user_id).email + ', user ' + @signup.user_id.to_s + ', event ' + @signup.hostevent_id.to_s + ', for ' + @signup.guest_count.to_s + ' guests'

      card = Stripe::Customer.create(
        :card => token,
        :description => desc
      )

      if card.nil? 
        flash[:error] = "Sorry, we encountered an error when processing the card. Please try again."
        redirect_to signup_path(@signup.permalink)
      elsif card.cards.data[0].cvc_check == 'fail'
        flash[:error] = "The card's security code is incorrect."
        redirect_to signup_path(@signup.permalink)
      elsif card.cards.data[0].address_zip_check == 'fail'
        flash[:error] = "The card's zip code failed validation."
        redirect_to signup_path(@signup.permalink)
      else
        charge = Stripe::Charge.create(
            :amount => amt, # in cents
            :currency => "usd",
            :customer => card.id,
            :description => desc
        )
        if charge.nil?
          flash[:error] = "Sorry, we encountered an error when processing the card. Please try again."
          redirect_to signup_path(@signup.permalink)
        else
          @signup.update_attribute(:card_id, card.id)
          @signup.update_attribute(:charge_id, charge.id)
          # @signup.update_attribute(:pay_portal_fee_cents, charge.fee)
          @signup.update_attribute(:card_last_4, charge.card.last4)
          @signup.update_attribute(:card_mth, charge.card.exp_month)
          @signup.update_attribute(:card_yr, charge.card.exp_year)
          @signup.update_attribute(:pay_failure_msg, charge.failure_message)

          if charge.captured
            @signup.update_attribute(:payment_status, 'Captured')
            @signup.update_attribute(:payment_amt, charge.amount)
            @signup.update_attribute(:confirmation_status, "Attending")
            UserMailer.sign_up_attending_alert(@event).deliver
            UserMailer.sign_up_payment_receipt(@signup, charge.amount).deliver
            flash[:success] = "Thank you for contributing to the event. Your seat is now reserved. Hope you enjoy the event!"
            redirect_to hostevent_path(@event.permalink)
          elsif charge.paid
            @signup.update_attribute(:payment_status, 'Pending')
            @signup.update_attribute(:payment_amt, charge.amount)
            @signup.update_attribute(:confirmation_status, "Attending")
            UserMailer.sign_up_attending_alert(@event).deliver
            UserMailer.sign_up_payment_receipt(@signup, charge.amount).deliver
            flash[:success] = "Thank you for contributing to the event. Your seat is now reserved. Hope you enjoy the event!"
            redirect_to hostevent_path(@event.permalink)
          elsif !charge.failure_message.nil?
            @signup.update_attribute(:payment_status, 'Failed')
            flash[:error] = "There was an error when processing your payment. " + charge.failure_message
            UserMailer.signup_error_payment_guest(@signup, charge.failure_message).deliver
            redirect_to signup_path(@signup.permalink)
          else
            flash[:error] = "There was an error when processing your payment. " + charge.failure_message
            redirect_to signup_path(@signup.permalink)
          end
        end
      end
      

      # Later... if want to charge existing card (https://stripe.com/docs/tutorials/charges)
        # customer_id = get_stripe_customer_id(card_id)

        # Stripe::Charge.create(
        #   :amount   => 1500, # $15.00 this time
        #   :currency => "usd",
        #   :customer => customer_id
        # )

      # Create the charge on Stripe's servers (1x)
        # begin
        #   charge = Stripe::Charge.create(
        #     :amount => amt, # amount in cents, again
        #     :currency => "usd",
        #     :card => token,
        #     :description => desc
        #   )
        # rescue Stripe::CardError => e
        #   # The card has been declined
        # end

    # for Braintree
      # result = Braintree::Transaction.sale(
      #   :amount => params[:signup][:payment_amt],
      #   :credit_card => {
      #     :number => params[:signup][:credit_card][:number],
      #     :cvv => params[:signup][:credit_card][:cvv],
      #     :expiration_month => params[:signup][:credit_card][:month],
      #     :expiration_year => params[:signup][:credit_card][:year]
      #   },
      #   :billing => {
      #       :postal_code => params[:signup][:credit_card][:postal_code]
      #   },
      #   :options => {
      #     :submit_for_settlement => true
      #   }
      # )
 
      #   if result.success?
      #     # result.transaction.id
      #     @signup.update_attribute(:payment_status, result.transaction.status)
      #     @signup.update_attribute(:confirmation_status, "Attending")
      #     flash[:success] = "Your payment was successfully processed."
      #     redirect_to hostevent_path(@signup.hostevent_id)
      #   else
      #     flash[:notice] = result.success?.to_s + result.message + result.to_s
      #     flash[:notice] = "Message: #{result.message}"
      #     p result.errors
      #     redirect_to signup_path(@signup.permalink)
      #   end
    end
  end

  def dispute_event
    @event = Hostevent.find_by_permalink(params[:hostevent_id])
    @signup = current_user.signups.where("confirmation_status = ? and hostevent_id = ?", "Attending", @event.id)

    if @signup.nil?
      flash[:error] = 'You must have attended this event in order to open a dispute for this event.'
    elsif params[:dispute] == "0"
      if @signup.first.update_attribute(:dispute_flag, 0)
        flash[:success] = 'We are happy that you resolved this dispute. We have successfully removed this dispute flag from the event. Thanks for your patience.'
      else
        flash[:error] = 'We encountered an error while removing this dispute. Please try again. If the problem persists, please contact us directly.'
      end
    else
      if @event.mealstarttime < (Date.today - 48.hours)
        flash[:error] = 'Unfortunately, the timeframe to open a dispute has passed. You can only open a dispute within 48 hours after the event start time. All the contributions has already been transferred to the host. If you are still unsatisfied, please contact the host directly to resolve this dispute.'
      else
        if @signup.first.update_attribute(:dispute_flag, 1)
          flash[:success] = 'We are sorry that you had to open a dispute with the host. We will contact you shortly to understand the problem and hope we can resolve this as soon as possible. Thank you for your patience.'
        else
          flash[:error] = 'We encountered an error while opening this dispute. Please try again. If the problem persists, please contact us directly.'
        end
        UserMailer.dispute_evt(current_user, @event, @signup.first.id).deliver
      end
    end

    redirect_to show_mypastevents_path
  end

  def host_rate_guest
    @evt = Hostevent.find_by_permalink(params[:hostevent_id])

    if @evt.user_id != current_user.id
      flash[:error] = 'You must be the host of the event in order to rate a guest who attended this event.'
    else
      @signup = @evt.signups.where("confirmation_status = ? and permalink = ?", "Attending", params[:signup_id])
      if @signup.nil?
        flash[:error] = 'The guest must have attended this event in order for you to rate him or her.'
      else
        if @signup.first.update_attribute(:host_rating_for_guest, params[:host_rating_guest])
          flash[:success] = 'Thanks for rating this guest.'
        else
          flash[:error] = 'We encountered an error while recording this rating in our system. Please try again. If the problem persists, please contact us directly.'
        end
      end
    end
    
    redirect_to hostevent_ratings_path(@evt.permalink)
  end

  private

    def correct_user
      @signup = current_user.signups.find_by_permalink(params[:permalink])

      if @signup.nil?
        signup_evt = Signup.find_by_permalink(params[:permalink]).hostevent
        flash[:error] = 'You must be signed up for this event to complete this action.'
        redirect_to hostevent_path(signup_evt.permalink) 
      end
    end
end
