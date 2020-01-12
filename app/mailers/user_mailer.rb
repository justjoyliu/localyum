class UserMailer < ActionMailer::Base
  # default from: "from@example.com"

  # no unsubscribe
    def registration_confirmation(user)
      @user = user
      mail(:to => user.email, :subject => "Welcome", :from => "\"Local Yum\" <welcome@localyum.me>")
    end

    def password_reset(user)
    	@user = user
    	mail(:to => user.email, :subject => "Reset Your Password", :from => "\"Local Yum\" <passwordreset@localyum.me>")
    end

    def contact_local_yum(msg)
    	@msg = msg
    	mail(:to => "contact@localyum.me", :subject => "Someone contacted Local Yum", :from => "\"Local Yum\" <contact@localyum.me>")
    end

    def dispute_evt(dispute_guest, event, signup_id)
      @signup_id = signup_id
      @evt = event
      @dispute_guest = dispute_guest
      @host = User.find_by_id(event.user_id)

      mail(:to => "contact@localyum.me", :subject => "Someone opened a dispute", :from => "\"Local Yum\" <dispute@localyum.me>")
    end

  # no unsubscribe, sign up related alerts
    def signed_up_alert(evt)
      @evt = evt
      host = User.find_by_id(@evt.user_id)
      mail(:to => host.email, :subject => "There is a seat request for your Local Yum event", :from => "\"Local Yum\" <notification@localyum.me>")
    end

    def sign_up_confirm_alert(signup)
      @signup = signup
      @guest = User.find_by_id(@signup.user_id)
      @evt = Hostevent.find_by_id(@signup.hostevent_id)
      mail(:to => @guest.email, :subject => "Your seat request has been confirmed by the Local Yum chef", :from => "\"Local Yum\" <notification@localyum.me>")
    end

    def sign_up_attending_alert(evt)
      @evt = evt
      host = User.find_by_id(@evt.user_id)
      mail(:to => host.email, :subject => "A guest is attending your Local Yum event", :from => "\"Local Yum\" <notification@localyum.me>")
    end

    def sign_up_payment_receipt(signup, pay_amount_cents)
      @signup = signup
      @pmt = pay_amount_cents
      @guest = User.find_by_id(@signup.user_id)
      @evt = Hostevent.find_by_id(@signup.hostevent_id)
      mail(:to => @guest.email, :subject => "Your seat reservation for a Local Yum event", :from => "\"Local Yum\" <notification@localyum.me>")
    end 
    
    def signup_error_payment_guest(signup, failure)
      @signup = signup
      @fail_msg = failure
      @guest = User.find_by_id(@signup.user_id)
      @evt = Hostevent.find_by_id(@signup.hostevent_id)
      mail(:to => @guest.email, :subject => "We could not process your Local Yum event contribution", :from => "\"Local Yum\" <notification@localyum.me>")
    end

    def signed_up_error_payment_ly(signup, failure)
      @signup = signup
      @fail_msg = failure
      mail(:to => "contact@localyum.me", :subject => "A signup payment has failed", :from => "\"Local Yum\" <error@localyum.me>")
    end

    def signup_guest_withdraw(signup, amt_refunded_cents, past_payment)
      @signup = signup
      @guest = User.find_by_id(@signup.user_id)
      @evt = Hostevent.find_by_id(@signup.hostevent_id)
      @refund = amt_refunded_cents
      @past_payment = past_payment
      mail(:to => @guest.email, :subject => "You have withdrawn your seat from a Local Yum event", :from => "\"Local Yum\" <notification@localyum.me>")
    end

    def signup_guest_withdraw_alert_host(signup)
      @signup = signup
      @evt = Hostevent.find_by_id(@signup.hostevent_id)
      host = User.find_by_id(@evt.user_id)
      mail(:to => host.email, :subject => "A guest has withdrawn from your Local Yum event", :from => "\"Local Yum\" <notification@localyum.me>")
    end

    def host_cancel_event_notify_guest(signup, amt_refunded_cents)
      @signup = signup
      @guest = User.find_by_id(@signup.user_id)
      @evt = Hostevent.find_by_id(@signup.hostevent_id)
      @refund = amt_refunded_cents
      mail(:to => @guest.email, :subject => "A host has cancelled a Local Yum event you have sign up for", :from => "\"Local Yum\" <notification@localyum.me>")
    end

  # no unsubscribe, event alerts
    def event_reminder_to_chef(evt)
      @evt = evt
      @chef = User.find_by_id(@evt.user_id)
      @guests = @evt.signups.where('confirmation_status in (?)', 'Attending')
      @comments = @evt.messages.where("public_flag = ?", 1).group("messagechain_id", "order_id", "message_content", "sender_id").sort{|a,b| b[:messagechain_id] <=> a[:messagechain_id]}
      if @guests.sum(:guest_count) > 0
        @paid_communal = @guests.where("own_group_flag = 0")
        @own_table = @guests.where("own_group_flag = 1")
        mail(:to => @chef.email, :subject => "Your upcoming event on Local Yum", :from => "\"Local Yum\" <alert@localyum.me>")
      end
    end

  # no unsubscribe, recipe event request
    def to_chef_recipe_evt_req(req)
      @req = req
      @chef = User.find(req.chef_id)
      @mi = Menuitem.find(req.menuitem_id)
      mail(:to => @chef.email, :subject => "Event Request for Local Yum Item", :from => "\"Local Yum\" <contact@localyum.me>")
    end

    def to_host_evt_proposal_from_chef(evt)
      @evt = evt  
      @req = Recipereq.find_by_hostevent_id(@evt.id)
      @mi = Menuitem.find(@req.menuitem_id)
      @chef = User.find(evt.chef_id)
      mail(:to => User.find(evt.user_id).email, :subject => "Event Creation Ready: Chef has proposed an event from your Local Yum request", :from => "\"Local Yum\" <contact@localyum.me>")
    end

    def to_chef_evt_approval_req(evt)
      @evt = evt  
      @host = User.find(evt.user_id)
      mail(:to => User.find(evt.chef_id).email, :subject => "Confirmation Needed: Host has opened an event from your Local Yum proposal", :from => "\"Local Yum\" <contact@localyum.me>")
    end

    def to_host_evt_chef_confirmed(evt)
      @evt = evt  
      mail(:to => User.find(evt.user_id).email, :subject => "Your Local Yum event is ready for sign up", :from => "\"Local Yum\" <contact@localyum.me>")
    end

  def invitation(evt, invite_guest_email, from_email, from_name)
    @evt = evt
    @invite_from = from_name

    mail(:bcc => invite_guest_email, :subject => "You are invited to a Local Yum event", :from => from_email)
  end

  def monthly_customized_newsletter(user)
    @user = user
    @requested_recipes = Recipereq.where("created_at >= ? and chef_id = ?", Date.today - 45, user.id).count(:group => "menuitem_id")

    @upcoming_as_guest = user.hostevents.where("mealstarttime > ?", Date.today).collect { |a| a.id }
    @upcoming_attending = user.hostevents.where("mealstarttime between ? and ? and confirmation_status in ('Confirmed', 'Attending')", Date.today, Date.today + 14).order("mealstarttime ASC")
    @upcoming_hosting = Hostevent.where("user_id = ? and mealstarttime between ? and ? and eventstatus = 'Open'", user.id, Date.today, Date.today + 14).order("mealstarttime ASC")

    @user_requested = Recipereq.where("user_id = ?", user.id)
    @req_menuitem_hostevent = Array.new
    if @upcoming_as_guest.length > 0
      unless @user_requested.nil?
        @user_requested.each do |r|
          Menuitem.find(r.menuitem_id).hostevents.where("mealstarttime between ? and ? and eventstatus = ? and id not in (?)", Date.today, Date.today + 90, "Open", @upcoming_as_guest).order("mealstarttime ASC").each do |e|
            @req_menuitem_hostevent << [r.menuitem_id, e.id]
          end
        end
        # @req_menuitem_ids = @user_requested.collect { |a| a.menuitem_id }
        # @hostevents = Hostevent.find_by_menuitem_id(@req_menuitem_ids).where("mealstarttime > ?", Date.today)
      end
    else
      unless @user_requested.nil?
        @user_requested.each do |r|
          Menuitem.find(r.menuitem_id).hostevents.where("mealstarttime between ? and ? and eventstatus = ?", Date.today, Date.today + 90, "Open").order("mealstarttime ASC").each do |e|
            @req_menuitem_hostevent << [r.menuitem_id, e.id]
          end
        end
        # @req_menuitem_ids = @user_requested.collect { |a| a.menuitem_id }
        # @hostevents = Hostevent.find_by_menuitem_id(@req_menuitem_ids).where("mealstarttime > ?", Date.today)
      end
    end
      

    @fav_chef = user.followed_users.collect { |a| a.id }
    unless @fav_chef.nil?
      if @upcoming_as_guest.length > 0
        @fav_chef_evts = Hostevent.where("mealstarttime between ? and ? and eventstatus = ? and user_id in (?) and id not in (?)", Date.today, Date.today + 90, "Open", @fav_chef, @upcoming_as_guest).order("mealstarttime ASC")
      else
        @fav_chef_evts = Hostevent.where("mealstarttime between ? and ? and eventstatus = ? and user_id in (?)", Date.today, Date.today + 90, "Open", @fav_chef).order("mealstarttime ASC")
      end
    end

    @already_news = (@upcoming_as_guest + @req_menuitem_hostevent.collect { |a| a[1] } + @fav_chef_evts.collect { |a| a.id }).uniq

    if @already_news.length > 0
      @otherevents = Hostevent.where("mealstarttime between ? and ? and eventstatus = ? and hostevents.user_id <> ? and hostevents.id not in (?)", Date.today, Date.today + 14, "Open", @user.id, @already_news).joins(:addressuser)  
    else
      @otherevents = Hostevent.where("mealstarttime between ? and ? and eventstatus = ? and hostevents.user_id <> ?", Date.today, Date.today + 14, "Open", @user.id).joins(:addressuser)
    end
  
    mail(:to => @user.email, :subject => "Upcoming Local Yum Events Waiting for You", :from => "\"Local Yum\" <newsletter@localyum.me>")
  end

end
