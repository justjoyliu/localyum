class SessionsController < ApplicationController

  def new
  end

  def create
  	user = User.find_by_email(params[:session][:email].downcase)

	  if user.nil?
      flash[:error] = 'We could not find your email on file. Try signing up or log in with Facebook.'
      redirect_to request_password_reset_path
    elsif (user.validation_flag.nil? or !user.validation_flag?) && user.authenticate(params[:session][:password])
      redirect_to activate_view_path(user.permalink)
      flash[:notice] = 'Your account has not been activated yet.'
    elsif !user.nil? && user.authenticate(params[:session][:password])
      	# Sign the user in and redirect to the user's show page.
      	sign_in user
      	#redirect_to user

        @upcomingevts = Hostevent.where("eventstatus = ? AND mealstarttime > ?", "Open", Time.now.to_datetime)
        if @upcomingevts.count < 1
          flash[:success] = 'Glad you can join us! We are just getting started and do not have many events yet. 
            We will email you suggestions of events once we have more hosts.'
        end
        
        redirect_back_or user_path(user.permalink) #method in sessions_helper.rb
        # redirect_to(session[:return_to] || user)
        # session.delete(:return_to) 
    elsif !user.fbid.nil?
      flash[:notice] = 'You have signed up using Facebook. Try to log in with Facebook instead.'
      redirect_to root_url
    else
	    flash[:error] = 'Invalid email/password combination'
	    redirect_to request_password_reset_path
	  end
  end

  def create_fb
    user = User.from_omniauth(env["omniauth.auth"])
    cookies[:remember_token] = { value:   user.remember_token,
                               expires: 60.minutes.from_now.utc }
    self.current_user = user

    @upcomingevts = Hostevent.where("eventstatus = ? AND mealstarttime > ?", "Open", Time.now.to_datetime)
    if @upcomingevts.count < 1
          flash[:success] = 'Glad you can join us! We are just getting started and do not have many events yet. 
            We will email you suggestions of events once we have more hosts.'
    end
    redirect_to user_path(user.permalink)
  end

  def destroy
  	sign_out
    redirect_to root_url
  end

end
