module SessionsHelper
  def sign_in(user)
	    #cookies.permanent[:remember_token] = user.remember_token sets to expire 20.years.from_now.utc
	    #After the cookie is set, on subsequent page views we can retrieve the user with code
	    #User.find_by_remember_token(cookies[:remember_token])
	    cookies[:remember_token] = { value:   user.remember_token,
	                             expires: 60.minutes.from_now.utc }
	    #if we do not include self. Rebuy would create a local variable current_user
	    self.current_user = user
      # session.delete(:return_to) 
  end

  def signed_in?
    if current_user.nil?
      # store_location
      return false
    else
      return true
    end
    # !current_user.nil?
  end

  def signed_in_store_location?
    if current_user.nil?
      store_location
      return false
    else
      return true
    end
  end

  def current_user=(user) #simply defines a method current_user= 
    	@current_user = user
  end

  def current_user
    	# ||= is "or equals" assignment operator
    	# set the @current_user instance variable to the user corresponding 
    	# to the remember token, but only if @current_user is undefined
    	@current_user ||= User.find_by_remember_token(cookies[:remember_token])
  end

  def current_user?(user)
    user == current_user
  end

  def signed_in_user
      #redirect_to signin_url, notice: "Please sign in." unless signed_in?
      #equivalent to 
      # flash[:notice] = "Please sign in."
      # redirect_to signin_url

      unless signed_in?
        store_location #method in sessions_helper.rb
        flash[:notice] = "Please sign up or log in."
        # redirect_to root_path
        redirect_to request_password_reset_path
      end
  end

  def active_user
    unless current_user.active_status?
        flash[:notice] = "You must be an active user in order to access the function. Consider re-activating your account in the account status section."
        redirect_to edit_user_path(current_user)
    end
  end

  def sign_out
    self.current_user = nil
    cookies.delete(:remember_token)
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  def store_location
    # session[:return_to] = request.url
    session[:return_to] = request.fullpath
  end

  def check_unsubscribed(email_array)
    send_invite_to = String.new
    unsub_emails = String.new

    email_array.each do |e|
      unsub = Unsubscribe.find_by_email(e)
      if unsub.nil?
        send_invite_to = send_invite_to + e + ', '
      else
        unsub_emails = unsub_emails + e + ', '
      end
    end

    return [send_invite_to, unsub_emails]
  end
end
