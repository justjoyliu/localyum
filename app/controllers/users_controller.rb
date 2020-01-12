class UsersController < ApplicationController
  before_filter :signed_in_user, 
                only: [:edit, :update, :deactivate, :show_myevents, :create_bank_acct, :show_myearnings, :my_recipebox, :following, :followers, :deactivate_account, :reactivate_account, :send_customized_newsletter, :all_user_stats]
  before_filter :correct_user,   only: [:edit, :update]
  before_filter :admin_user,     only: [:destroy, :send_customized_newsletter, :all_user_stats, :send_reminders]
  # protect_from_forgery :except => :create_bank_acct 
  # skip_before_filter :verify_authenticity_token
  
  # basic
    def hosts
        #@users = User.all
        @hosts = User.joins(:addressusers, :menuitems).where("metroarea = ? and active_status = 1 and avatar_file_name is not null and menupic_file_name is not null", params[:metroarea]).group("users.id")
        @users = @hosts.paginate(page: params[:page])
    end

    def show
      @user_agent = UserAgent.parse(request.env["HTTP_USER_AGENT"])
      @user = User.find_by_permalink(params[:permalink])
      # @hostevents = @user.hostevents.paginate(page: params[:page])
      @recipes = @user.menuitems.where("menupic_file_name is not null")
      @chef = @user 
      @title = @user.name

      @user_as_guest_r = @user.user_as_guest_rating
      # @attended_cnt =  @user.signups.where("confirmation_status = 'Attending'").count
      
      @hosted_evts = @user.hostevents_as_host.where("eventstatus = ?", "Open")
      @host_upcoming = @user.upcoming_openevents_as_host
      @host_cancel_count = @user.host_penalties.count('hostevent_id', :distinct => true)
      @past_evts = Hostevent.where("user_id in (?) and eventstatus = ? and mealstarttime < ? and host_net_earnings_cents > 0", @user.id, "Open", Date.today)

      @signup_with_ratings = Signup.where("hostevent_id in (?) and (taste_rating is not null or experience_rating is not null)", @user.hostevents_as_host_ids).order("updated_at DESC").paginate(:per_page => 4, :page => params[:page])

      if signed_in?
        @msgchain = Messagechain.new
        @msg = @msgchain.messages.build
      else
        signed_in_store_location?
        # flash[:notice] = "Create a Local Yum account or Log In above to request the chef's recipes or to request seats at his/her events."
      end

    end

    # def new
    #   @user = User.new
    # end

    def create
      already_user = User.find_by_email(params[:user][:email])

      if !already_user.nil?
        if !already_user.fbid.nil?
          flash[:notice] = 'You have already registered with a Facebook account. Try to sign in using Facebook.'
        else
          flash[:notice] = 'You have already registered before. Try login in with this email'
        end
        redirect_to root_path
      elsif params[:user][:email].blank? or params[:user][:name].blank?
        flash[:warning] = 'Please fill in your name, email, password, and confirm password before clicking the Create Account button'
        redirect_to root_path
      else
        @user = User.create(params[:user])
        # @code = SecureRandom.hex(8)
        @code = SecureRandom.urlsafe_base64

        unless @user.nil? 
          if @user.update_attribute(:validation_code, @code) and @user.update_attribute(:validation_flag, false)
            UserMailer.registration_confirmation(@user).deliver
            redirect_to root_path
            flash[:notice] = 'Your account was created! Please check your email for an activation link.' 
          else
            render root_path
          end 
        else
          flash[:error] = 'We are sorry. We had trouble creating your account. Please try again.'
          render root_path
        end
      end
      
      # if @user.save
      #   sign_in @user
      #   # Handle a successful save.
      #   flash[:success] = "Thanks for signing up!"
      #   redirect_to edit_user_path(@user)
      # else
      #   render root_path
      # end
    end

    def edit
     # @user = User.find_by_permalink(params[:permalink])
     @user_agent = UserAgent.parse(request.env["HTTP_USER_AGENT"])
    end

    def update
      #@user = User.find_by_permalink(params[:permalink])
      if params[:user].has_key?(:yummer_flag)
        if (params[:user][:yummer_flag].to_i + params[:user][:host_flag].to_i + params[:user][:chef_flag].to_i) == 0
          flash[:error] = 'You must set up your Local Yum account to be 1 or more of the account types.'
        else 
          @user.update_attributes(params[:user]) 
          flash[:success] = "Thanks! Your profile has been updated."
          sign_in @user
        end
        redirect_to edit_user_path(@user.permalink)
      elsif @user.update_attributes(params[:user]) 
        if params[:user].has_key?(:link_facebook) and !params[:user][:link_facebook].empty?
        # if update_values.has_key?(:link_facebook)
          unless params[:user][:link_facebook] =~ /^htt(p|ps):\/\//
            @user.update_attribute(:link_facebook, 'http://' + params[:user][:link_facebook]) 
          end
        end

        if params[:user].has_key?(:link_twitter) and !params[:user][:link_twitter].empty?
        # if update_values.has_key?(:link_twitter)
          unless params[:user][:link_twitter] =~ /^htt(p|ps):\/\//
            @user.update_attribute(:link_twitter, 'http://' + params[:user][:link_twitter]) 
          end
        end

        if params[:user].has_key?(:link_pintrest) and !params[:user][:link_pintrest].empty?
        # if update_values.has_key?(:link_pintrest)
          unless params[:user][:link_pintrest] =~ /^htt(p|ps):\/\//
            @user.update_attribute(:link_pintrest, 'http://' + params[:user][:link_pintrest]) 
          end
        end

        if params[:user].has_key?(:link_foodblog) and !params[:user][:link_foodblog].empty?
        # if update_values.has_key?(:link_foodblog)
          unless params[:user][:link_foodblog] =~ /^htt(p|ps):\/\//
            @user.update_attribute(:link_foodblog, 'http://' + params[:user][:link_foodblog]) 
          end
        end
        
        flash[:success] = "Thanks! Your profile has been updated."
        # flash[:success] = update_values.to_s
        sign_in @user
        redirect_to edit_user_path(@user.permalink)
      else
        if !@user.errors[:avatar_file_size].empty?
          flash[:error] = 'Your profile picture must be less than 5MB.'
        elsif !@user.errors[:avatar_content_type].empty?
          flash[:error] = "Your profile picture must be in jpeg, png, or gif format."
        else
          flash[:warning] = "We could not update all your requests. Please try to save updates again. If this error continues, please reach out to us at contact@localyum.me"
        end
        
        redirect_to edit_user_path(@user.permalink)
      end
    end

  # acct activation and password reset
    def account_activate
      # @user = User.find_by_email(params[:email])
      # @activation_code = params[:confirmation]

      @user = User.find_by_validation_code(params[:code])

      if @user.nil?
        flash[:error] = "We could not activate your account. Your activation code might have expired or your account is already activated. Please try to login in."
        redirect_to root_path
      elsif @user.validation_flag?
        # sign_in @user
        flash[:notice] = "Your account was already activated. Try to login with your email and password"
        redirect_to root_path
      elsif @user.validation_code == params[:code]
        if @user.update_attribute(:validation_flag, true)
          @user.update_attribute(:validation_code, nil)
          # sign_in @user
          flash[:success] = "Congratulations! Your account is now activated. For security purposes, please login to access your account."
          redirect_to root_path
        else
          flash[:error] = "Sorry, our system could not activate your account."
          redirect_to activate_view_path(@user.permalink)
        end
      else
        flash[:error] = "We could not activate your account. Your activation code might have expired."
        redirect_to activate_view_path(@user.permalink)
      end
      # @session = Session.new(:confirmation => params[:confirmation], :email => params[:email])
    end

    def activate_view
      @user = User.find_by_permalink(params[:permalink])
    end

    def resend_activation
      @user = User.find_by_permalink(params[:permalink])

      if @user.validation_flag?
        # sign_in @user
        flash[:notice] = "Your account was already activated. Please login with your email and password."
        redirect_to root_path
      elsif !@user.nil?
        @code = SecureRandom.urlsafe_base64
        if @user.update_attribute(:validation_code, @code) and @user.update_attribute(:validation_flag, false)
          UserMailer.registration_confirmation(@user).deliver
          redirect_to root_path
          flash[:notice] = 'We just sent your activation code. Please check your email for an activation link.' 
        else
          render root_path
        end 
      else
        flash[:error] = "We could not find your email in our system. Please register your email and we will send you an activation link."
        render root_path
      end
    end

    def request_password_reset
    end

    def email_password_reset
      user = User.find_by_email(params[:email])
      if user
        user.send_password_reset 
        redirect_to root_path, :notice => "An email has been sent with password reset instructions."
      else
        flash[:error] = "We could not find your email in our system. Please create an account first."
        redirect_to root_path
      end 
    end

    def password_reset
      @user = User.find_by_password_reset_token!(params[:code])

      if @user.nil? or @user.password_reset_sent_at < 8.hours.ago
        flash[:error] = "The password reset link is no longer valid. Would you like to resend another?"
        redirect_to request_password_reset_path
      end
    end

    def update_password_reset
      @user = User.find_by_permalink(params[:permalink])

      if @user.password_reset_sent_at < 8.hours.ago
        redirect_to request_password_reset_path, :alert => "Password reset has expired. Would you like us to resend another?"
      elsif @user.update_attributes(params[:user])
        # sign_in @user 
        flash[:success] = "Your password has been reset. Please login with the new password."
        redirect_to root_path
      else
        redirect_to root_path, :alert => "We encountered an error during the password reset process. Would you mind trying again?"
      end
    end

  # deactivating accts
    def destroy
      # User.find_by_permalink(params[:permalink]).destroy
      # flash[:success] = "User destroyed."
      # redirect_to users_url
    end

    def deactivate_account
      @upcoming_hostevents = current_user.upcoming_openevents_as_host
      @upcoming_attending = current_user.upcomingevents_as_guest.where("confirmation_status not in (?)", "Withdrawn")
      @followings_followers = Relationship.where("follower_id = ? or followed_id = ?", current_user.id, current_user.id)

      if current_user.update_attribute(:active_status, :false)
        flash[:warning] = 'Your account has been de-activated'
        sign_in current_user
        redirect_to edit_user_path(current_user.permalink)
      end 

      @upcoming_hostevents.each do |hostevt|
        hostevt.hostevent_cancellation 
      end

      @upcoming_attending.each do |attd|
        current_user.signups.find_by_hostevent_id(attd.id).signup_withdraw 
      end

      @followings_followers.each do |r|
        r.destroy 
      end
    end

    def reactivate_account
      if current_user.update_attribute(:active_status, 1)
        flash[:success] = 'Your account has been re-activated'
        sign_in current_user
        redirect_to edit_user_path(current_user.permalink)
      else
        flash[:error] = 'Sorry, we could not re-activate your account. Please try again. If the problem persists, please contact us.'
        redirect_to edit_user_path(current_user.permalink)
      end 
    end

  # following
    def following
      @title = "Favorite Chefs"
      # @user = User.find_by_permalink(params[:permalink])
      # @users = @user.followed_users.paginate(page: params[:page])

      @users = current_user.followed_users
      unless @users.nil?
        @user_ids = @users.collect { |a| a.id }
        @hostevents = Hostevent.where("mealstarttime > ? and eventstatus = ? and user_id in (?)", Date.today, "Open", @user_ids).order("mealstarttime ASC")
        @recipes = Menuitem.where("user_id in (?) and menupic_file_name is not null", @user_ids)
      end
      
      render 'show_follow'
    end

    # def followers
    #   @title = "Your Followers"
    #   @users = current_user.followers
    #   # @user = User.find_by_permalink(params[:permalink])
    #   # @users = @user.followers.paginate(page: params[:page])
    #   render 'show_follow'
    # end

  # event summaries
    def show_myevents

      @upcoming_hostevents = current_user.upcomingevents_as_host #.hostevents_as_host.where("mealstarttime > ?", @today_datetime)
      @upcoming_open_hostevents = @upcoming_hostevents.where("eventstatus = ?", "Open")
      @upcoming_chef_evts = Hostevent.where('chef_id = ? and user_id != ? and eventstatus = ? and startdate >= ?', current_user.id, current_user.id, "Open", Date.today)

      @upcoming_attending = current_user.upcomingevents_as_guest #.hostevents.where("mealstarttime > ?", @today_datetime)
      @upcoming_confirmed_attending = @upcoming_attending.where("confirmation_status = ?", "Confirmed")
      @upcoming_paid_attending = @upcoming_attending.where("confirmation_status = ?", "Attending")
      @upcoming_waiting_cnt = @upcoming_attending.where("confirmation_status = ?", "Waiting").count
      @upcoming_withdrawn_cnt = @upcoming_attending.where("confirmation_status = ?", "Withdrawn").count

      @attending = @upcoming_attending.collect { |a| a.id }
      @upcoming_signups = current_user.signups.where("hostevent_id in (?)", @attending)
      @hosting = @upcoming_hostevents.collect { |a| a.id }
      @all_events_ids = @attending + @hosting
      
      # paginate option
      # @all_events = Hostevent.where("id in (?)", @all_events_ids).order("mealstarttime ASC").paginate(:per_page => 3, :page => params[:page])
      # @all_events = current_user.hostevents.where("mealstarttime > ?", @today_datetime).order("mealstarttime DESC").paginate(:per_page => 3, :page => params[:page])
      
      @host_pending_action = 0 
      @host_pending_action_evts = Array.new
      @host_confirmed = 0 
      @host_paid = 0 

      @upcoming_open_hostevents.each do |e|
        if e.signups.where("confirmation_status = ? and confirmation_host = ?", "Waiting", "0").count > 0
          @host_pending_action += e.signups.where("confirmation_status = ? and confirmation_host = ?", "Waiting", "0").count
          @host_pending_action_evts << e
        end
        # @host_confirmed += e.signups.where("confirmation_status = ?", "Confirmed").count
        # @host_paid += e.signups.where("confirmation_status = ?", "Attending").count
      end 

      if params.has_key?(:host_pending_action)
        @all_events = @host_pending_action_evts 
      elsif params.has_key?(:guest_pending_action)
        @all_events = @upcoming_confirmed_attending
      else
        @all_events = Hostevent.where("id in (?)", @all_events_ids).order("mealstarttime ASC")
      end
    end
    
    def show_mypastevents
      @user = User.find_by_permalink(params[:permalink])

      if signed_in? and current_user.id = @user.id
        @hosted = current_user.hostevents_as_host.where("eventstatus not in ('Deleted') and mealstarttime < ?", Date.today)
        @host_completed = @hosted.where("eventstatus = ?", "Open")

        @attended = current_user.hostevents.where("mealstarttime < ? and confirmation_status = ?", Date.today, "Attending")

        @attended_id = @attended.collect { |a| a.id }
        @attended_signups = current_user.signups.where("hostevent_id in (?)", @attended)
        @hosted_id = @hosted.collect { |a| a.id }
        @all_events_ids = @attended_id + @hosted_id
        
        @all_events = Hostevent.where("id in (?)", @all_events_ids).order("mealstarttime DESC").paginate(:per_page => 3, :page => params[:page])
        
        @messagechain = Messagechain.new
        @cmt = @messagechain.messages.build
        # @all_events = current_user.hostevents.where("mealstarttime > ?", @today_datetime).order("mealstarttime DESC").paginate(:per_page => 3, :page => params[:page])
      else
        @all_events = Hostevent.where("user_id in (?) and eventstatus = ? and mealstarttime < ? and host_net_earnings_cents > 0", @user.id, "Open", Date.today).order("mealstarttime DESC").paginate(:per_page => 8, :page => params[:page])
      end
      
    end

    def show_myearnings
      # @today_date = Time.new.to_date
      # @today_hour = Time.new.strftime("%H").to_i
      # @today_datetime = DateTime.new(@today_date.year, @today_date.month, @today_date.day, @today_hour)

      # @host_completed = current_user.hostevents_as_host.where("eventstatus in ('Open') and mealstarttime < ?", (Date.today - 48.hours))
      @host_completed = Hostevent.where("eventstatus in ('Open') and mealstarttime < ? and (user_id = ? or chef_id = ?)", (Date.today), current_user.id, current_user.id)
      @current_bank_acct = current_user.bank_acct_info

      @tot_revenue = current_user.total_revenue
      @potential_revenue = current_user.potential_revenue
      
      # look up of past transfer attempts
        if current_user.userbalances.find_by_status("paid").nil?
          # @paid_out_amt = current_user.hostevents_as_host.where("payout_status in ('paid') and host_net_earnings_cents > 0 and payout_non_ach_info is not null").sum  :host_net_earnings_cents
          @paid_out_amt = 0 
        else
          # @paid_out_amt = (current_user.userbalances.where("status in ('paid')").sum  :amount) + (current_user.hostevents_as_host.where("payout_status in ('paid') and host_net_earnings_cents > 0 and payout_non_ach_info is not null").sum  :host_net_earnings_cents)
          @paid_out_amt = (current_user.userbalances.where("status in ('paid')").sum  :amount)
        end
        
        if current_user.userbalances.find_by_status("pending").nil?
          @pending_amt = 0
          # @pending_amt = current_user.hostevents_as_host.where("payout_status in ('pending') and host_net_earnings_cents > 0 and payout_non_ach_info is not null").sum  :host_net_earnings_cents
        else
          @pending_amt = (current_user.userbalances.where("status in ('pending')").sum  :amount)
          # @pending_amt = (current_user.userbalances.where("status in ('pending')").sum  :amount) + (current_user.hostevents_as_host.where("payout_status in ('pending') and host_net_earnings_cents > 0 and payout_non_ach_info is not null").sum  :host_net_earnings_cents)
        end
        
        if current_user.userbalances.find_by_status("failed").nil?
          @failed = 0
        else
          @failed = ((current_user.userbalances.where("status in ('failed')").count) * 200)
        end      
    
      @payout = current_user.available_for_payout(@failed)
    end

    def create_bank_acct
      # flash[:error] = params[:stripeToken]
      # evts = current_user.hostevents_as_host.where("eventstatus in ('Open') and mealstarttime < ? and host_net_earnings_cents > 0", Date.today)

      # paid_out_amt = current_user.userbalances.where("status in ('paid')").sum  :amount
      # pending_amt = current_user.userbalances.where("status in ('pending')").sum  :amount
      # failed = current_user.userbalances.where("status in ('failed')").count

      if current_user.userbalances.find_by_status("paid").nil?
        # paid_out_amt = current_user.hostevents_as_host.where("payout_status in ('paid') and host_net_earnings_cents > 0 and payout_non_ach_info is not null").sum  :host_net_earnings_cents
        paid_out_amt = 0 
      else
        # paid_out_amt = (current_user.userbalances.where("status in ('paid')").sum  :amount) + (current_user.hostevents_as_host.where("payout_status in ('paid') and host_net_earnings_cents > 0 and payout_non_ach_info is not null").sum  :host_net_earnings_cents)
        paid_out_amt = (current_user.userbalances.where("status in ('paid')").sum  :amount)
      end
      
      if current_user.userbalances.find_by_status("pending").nil?
        pending_amt = 0
        # pending_amt = current_user.hostevents_as_host.where("payout_status in ('pending') and host_net_earnings_cents > 0 and payout_non_ach_info is not null").sum  :host_net_earnings_cents
      else
        pending_amt = (current_user.userbalances.where("status in ('pending')").sum  :amount)
        # pending_amt = (current_user.userbalances.where("status in ('pending')").sum  :amount) + (current_user.hostevents_as_host.where("payout_status in ('pending') and host_net_earnings_cents > 0 and payout_non_ach_info is not null").sum  :host_net_earnings_cents)
      end
      
      if current_user.userbalances.find_by_status("failed").nil?
        failed = 0
      else
        failed = ((current_user.userbalances.where("status in ('failed')").count) * 200)
      end

      tot_revenue = current_user.total_revenue
      @payout = current_user.available_for_payout(failed)

      # before event request and chef and host can be different (payout goes to chef)
      # payout_evts = current_user.hostevents_as_host.where("eventstatus in ('Open') and mealstarttime < ? and host_net_earnings_cents > 0 and (payout_status not in ('paid', 'pending') or payout_status is null)", (Date.today - 48.hours))
      payout_evts = Hostevent.where("chef_id = ? and eventstatus in ('Open') and mealstarttime < ? and host_net_earnings_cents > 0 and (payout_status not in ('paid', 'pending') or payout_status is null)", current_user.id, (Date.today - 48.hours))

      if params[:withdraw_method] == "update_bank_info"
        # Stripe.api_key = "sk_test_sWNbWe3J6bswuVe7Qjl6kuFu"
        Stripe.api_key = "sk_live_fORb3CqCSmxov9LudZx42ziZ"

          desc = 'user_id: ' + current_user.id.to_s
          
          if current_user.recipient_id.nil?
            recipient = Stripe::Recipient.create(
              :name => params[:name],
              :type => params[:entity_type],
              :email => current_user.email,
              :bank_account => params[:stripeToken], 
              :description => desc
              # :tax_id => params[:taxid]
            )

            current_user.update_attribute(:recipient_id, recipient.id)
          else
            recipient = Stripe::Recipient.retrieve(current_user.recipient_id)
            recipient.name = params[:name]
            recipient.type = params[:entity_type]
            recipient.bank_account = params[:stripeToken]
            # recipient.tax_id = params[:taxid]
            recipient.save
            current_user.update_attribute(:recipient_id, recipient.id)
          end
          
          sign_in current_user

          # if recipient.verified
          if !recipient.active_account.nil?
            flash[:success] = "Your bank account information has been updated in our system."
          else
            flash[:error] = "We were unable to verify your identify. To make sure we transfer your money into the correct account, please verify that the information you entered is accurate and try again."
          end
          
      elsif @payout[:payout] <= 0 or tot_revenue < (paid_out_amt + pending_amt + failed + @payout[:penalty_from_cancelled_events])
        flash[:error] = 'You do not have any available balance to transfer out.'
      elsif @payout[:payout] > (tot_revenue - paid_out_amt - pending_amt - failed - @payout[:penalty_from_cancelled_events])
        flash[:error] = 'We apologize for the inconvenience. We encountered an error in calculating your available balance. Please contact us to resolve this issue (in the message, please mention this error.'
      else
        if params[:withdraw_method] == "ach"
          # Stripe.api_key = "sk_test_sWNbWe3J6bswuVe7Qjl6kuFu"
          Stripe.api_key = "sk_live_fORb3CqCSmxov9LudZx42ziZ"

          desc = 'user_id: ' + current_user.id.to_s
          
          if current_user.recipient_id.nil?
            recipient = Stripe::Recipient.create(
              :name => params[:name],
              :type => params[:entity_type],
              :email => current_user.email,
              :bank_account => params[:stripeToken], 
              :description => desc
              # :tax_id => params[:taxid]
            )

            current_user.update_attribute(:recipient_id, recipient.id)
          else
            recipient = Stripe::Recipient.retrieve(current_user.recipient_id)
            recipient.name = params[:name]
            recipient.type = params[:entity_type]
            recipient.bank_account = params[:stripeToken]
            # recipient.tax_id = params[:taxid]
            recipient.save
            current_user.update_attribute(:recipient_id, recipient.id)
          end
          
          sign_in current_user

          # if recipient.verified
          if !recipient.active_account.nil? 
            transfer = Stripe::Transfer.create(
                :amount => @payout[:payout], # amount in cents
                :currency => "usd",
                :recipient => current_user.recipient_id,
                :statement_descriptor => "Local Yum event revenue"
            )

            payout_evts.each do |e|
              unless e.signups.where("confirmation_status in ('Attending') and dispute_flag = 1").count > 0 
                e.update_attribute(:transfer_id, transfer.id)
                e.update_attribute(:payout_method, "ach")
                e.update_attribute(:payout_status, transfer.status)
                e.update_attribute(:payout_date, Date.today)
              end
            end

            bal = current_user.userbalances.build(
                :amount => transfer.amount, 
                :status => transfer.status, 
                # :stripe_fee => transfer.fee, 
                :transfer_id => transfer.id)
            bal.save

            flash[:success] = 'We have received your transfer request and are processing this transfer. You should expect the funds to be in your bank account within 7 to 10 business days. If any information was mis-entered, we will not be able to process this transfer and you will see the funds back in your Local Yum account as available balance, but with a $1 penalty.'
          else
            flash[:error] = "We were unable to verify your identify. To make sure we transfer your money into the correct account, please verify that the information you entered is accurate and try again."
          end
          
        elsif params[:withdraw_method] == "existing_ach"
          if current_user.recipient_id.nil?
            flash[:error] = 'We are sorry, but we no longer have a valid verified bank account on file. Please create a new one for us to complete the transfer.' 
          else

            # Stripe.api_key = "sk_test_sWNbWe3J6bswuVe7Qjl6kuFu"
            Stripe.api_key = "sk_live_fORb3CqCSmxov9LudZx42ziZ"

            recipient = Stripe::Recipient.retrieve(current_user.recipient_id)

            # if recipient.verified
            if !recipient.active_account.nil?
              transfer = Stripe::Transfer.create(
                  :amount => @payout[:payout], # amount in cents
                  :currency => "usd",
                  :recipient => current_user.recipient_id,
                  :statement_descriptor => "Local Yum event revenue"
              )

              payout_evts.each do |e|
                unless e.signups.where("confirmation_status in ('Attending') and dispute_flag = 1").count > 0 
                  e.update_attribute(:transfer_id, transfer.id)
                  e.update_attribute(:payout_method, "ach")
                  e.update_attribute(:payout_status, transfer.status)
                  e.update_attribute(:payout_date, Date.today)
                  e.update_attribute(:payout_non_ach_info, nil)
                end
              end

              bal = current_user.userbalances.build(
                  :amount => transfer.amount, 
                  :status => transfer.status, 
                  # :stripe_fee => transfer.fee, 
                  :transfer_id => transfer.id)
              bal.save

              flash[:success] = 'We have received your transfer request and are processing this transfer. You should expect the funds to be in your bank account within 7 to 10 business days. If any information was mis-entered, we will not be able to process this transfer and you will see the funds back in your Local Yum account as available balance, but with a $1 penalty.'
            else
              flash[:error] = "We were unable to verify your identify. To make sure we transfer your money into the correct account, please verify that the information you entered is accurate and try again."
            end
          end
        elsif params[:withdraw_method] == "paypal"
          payout_evts.each do |p|
            unless p.signups.where("confirmation_status in ('Attending') and dispute_flag = 1").count > 0 
              p.update_attribute(:payout_non_ach_info, params[:paypal_email])
              p.update_attribute(:payout_method, "paypal")
              p.update_attribute(:payout_status, "pending")
              p.update_attribute(:payout_date, Date.today)
            end
          end
          bal = current_user.userbalances.build(
                  :amount => @payout[:payout], 
                  :status => "pending",
                  :transfer_id => "paypal")
          bal.save
        else
          flash[:error] = "Please choose either bank transfer or PayPal method to transfer your available balance."
        end
      end
      
      redirect_to show_myearnings_path
    end

  # newsletters and reminders
    def send_customized_newsletter
      if current_user.admin?
        User.all.each do |u|
          if Unsubscribe.find_by_email(u.email).nil?
            UserMailer.monthly_customized_newsletter(u).deliver
          end
        end
        flash[:success] = 'Newsletters have been delivered.'
        redirect_to edit_user_path(current_user.permalink)
      else
        flash[:error] = 'You do not have access to send newsletters to our users.'
        redirect_to root_path
      end
    end

    def send_customized_newsletter_test
      if current_user.admin?
        UserMailer.monthly_customized_newsletter(current_user).deliver
        UserMailer.monthly_customized_newsletter(User.find(1)).deliver
        flash[:success] = 'Newsletters have been delivered.'
        redirect_to edit_user_path(current_user.permalink)
      else
        flash[:error] = 'You do not have access to send newsletters to our users.'
        redirect_to root_path
      end
    end

    def send_reminders
      # email reminder to chef who have events the next day
      reminders_sent_cnt = 0
      @upcomingevts = Hostevent.where("eventstatus in ('Open') and mealstarttime between ? and ?", (Date.today + 24.hours), (Date.today + 48.hours)) 
      
      @upcomingevts.all.each do |evt|
        UserMailer.event_reminder_to_chef(evt).deliver
        reminders_sent_cnt += 1
      end
      
      flash[:success] = reminders_sent_cnt.to_s + ' event notifications have been delivered.'
      redirect_to edit_user_path(current_user.permalink)
    end

  # admin
    def all_user_stats
      @user_cnt = User.all.group_by { |m| m.created_at.beginning_of_week }.sort.reverse
      @updated_last = User.all.group_by { |m| m.updated_at.beginning_of_week }.sort.reverse
    end

  private

    def correct_user
      @user = User.find_by_permalink(params[:permalink])
  
      unless current_user?(@user)
        redirect_to(root_path)  
        flash[:error] = 'You must be signed in as this user in order to access this function.'
      end
  
      # current_user? method defined in app/helpers/sessions_helper.rb
    end

    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end
end
