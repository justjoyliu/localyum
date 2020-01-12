Stripe.api_key = stripe_key
STRIPE_PUBLIC_KEY = stripe_public

# StripeEvent.setup do
StripeEvent.configure do |events|
  events.subscribe 'charge.failed' do |event|
    # Define subscriber behavior based on the event object
    # event.class #=> Stripe::Event
    # event.type  #=> "charge.failed"
    # event.data  #=> { ... }

    signup_stripe_charge = Signup.find_by_charge_id(event.data.object.id)
    unless signup_stripe_charge.nil?
    	signup_stripe_charge.update_attribute(:payment_status, "Failed")
      signup_stripe_charge.update_attribute(:confirmation_status, "Confirmed")  
    	signup_stripe_charge.update_attribute(:pay_failure_msg, event.data.object.failure_message)  
      # UserMailer.signed_up_error_payment_ly(signup_stripe_charge, event.data.object.failure_message).deliver
      UserMailer.signup_error_payment_guest(signup_stripe_charge, event.data.object.failure_message).deliver
    end
  end

  events.subscribe 'charge.refunded' do |event|
    signup_stripe_charge = Signup.find_by_charge_id(event.data.object.id)
    unless signup_stripe_charge.nil?
		  signup_stripe_charge.update_attribute(:payment_status, "Refunded") 
      signup_stripe_charge.update_attribute(:confirmation_status, "Withdrawn")  
    	signup_stripe_charge.update_attribute(:refund_amt_cent, event.data.object.amount_refunded)  
    end
  end

  events.subscribe 'charge.captured' do |event|
    signup_stripe_charge = Signup.find_by_charge_id(event.data.object.id)
    unless signup_stripe_charge.nil?
    	if event.data.object.paid and event.data.object.captured and !event.data.object.refunded and event.data.object.dispute.nil?
    		signup_stripe_charge.update_attribute(:payment_status, "Captured") 
    		signup_stripe_charge.update_attribute(:payment_amt, event.data.object.amount) 
    	end 
    end
  end

  # events.subscribe 'charge.dispute.created', 'charge.dispute.updated', 'charge.dispute.closed' do |event|
  events.subscribe 'charge.dispute.created' do |event|
  	signup_stripe_charge = Signup.find_by_charge_id(event.data.object.id)
    unless signup_stripe_charge.nil?
		  signup_stripe_charge.update_attribute(:payment_status, "Disputed") 
    	signup_stripe_charge.update_attribute(:dispute_flag, 1)  
    	signup_stripe_charge.update_attribute(:pay_failure_msg, event.data.object.dispute)  
    end
  end

  events.subscribe 'charge.dispute.updated' do |event|
    signup_stripe_charge = Signup.find_by_charge_id(event.data.object.id)
    unless signup_stripe_charge.nil?
      signup_stripe_charge.update_attribute(:payment_status, "Disputed") 
      signup_stripe_charge.update_attribute(:dispute_flag, 1)  
      signup_stripe_charge.update_attribute(:pay_failure_msg, event.data.object.dispute)  
    end
  end

  events.subscribe 'charge.dispute.closed' do |event|
    signup_stripe_charge = Signup.find_by_charge_id(event.data.object.id)
    unless signup_stripe_charge.nil?
      signup_stripe_charge.update_attribute(:payment_status, "Disputed") 
      signup_stripe_charge.update_attribute(:dispute_flag, 1)  
      signup_stripe_charge.update_attribute(:pay_failure_msg, event.data.object.dispute)  
    end
  end

  # events.subscribe 'transfer.paid', 'transfer.failed' do |event|
  events.subscribe 'transfer.paid' do |event|
    tr = Userbalance.find_by_transfer_id(event.data.object.id)
    tr_events = Hostevent.where('transfer_id = ?', event.data.object.id)
    tr_status = event.data.object.status

    unless tr.nil?
      tr.update_attribute(:status, tr_status)
    end

    tr_events.each do |e|
      e.update_attribute(:payout_status, tr_status)
    end
  end

  events.subscribe 'transfer.failed' do |event|
    tr = Userbalance.find_by_transfer_id(event.data.object.id)
    tr_events = Hostevent.where('transfer_id = ?', event.data.object.id)
    tr_status = event.data.object.status

    unless tr.nil?
      tr.update_attribute(:status, tr_status)
    end

    tr_events.each do |e|
      e.update_attribute(:payout_status, tr_status)
    end
  end

  # subscribe 'customer.created', 'customer.updated' do |event|
  #   # Handle multiple event types
  # end

  # subscribe do |event|
    # Handle all event types - logging, etc.
  # end
end