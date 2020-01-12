class UnsubscribesController < ApplicationController


  def new
  end

  def create
    if params.has_key?(:user_id)
      if signed_in? 
        if current_user.unsubscribe.nil?
          Unsubscribe.create(:email => current_user.email, :user_id => current_user.id)
          flash[:notice] = 'You are unsubscribed now.' 
        else
          flash[:notice] = 'You are already unsubscribed.'
        end
      end
      redirect_to edit_user_path(current_user.permalink)
    elsif Unsubscribe.find_by_email(params[:unsubscribe][:email]).nil?
      @unsub = Unsubscribe.create(params[:unsubscribe])
      @user = User.find_by_email(params[:unsubscribe][:email])

      if !@unsub.nil? and !@user.nil?
        @unsub.update_attribute(:user_id, @user.id)
        flash[:notice] = 'You are unsubscribed now.' 

        if signed_in?
          redirect_to edit_user_path(@user)
        else
          redirect_to root_path 
        end
      elsif @unsub.nil?
        flash[:error] = 'We are sorry. We had trouble unsubscribing you. Please try again.'
        redirect_to new_unsubscribe_path
      else
        flash[:notice] = 'You are unsubscribed now.'
        redirect_to root_path
      end
    else
      flash[:notice] = 'You are already unsubscribed.'
      redirect_to root_path
    end
  end

  def destroy
    if params.has_key?(:email)
      @unsub = Unsubscribe.find_by_email(params[:email])
      @user = User.find_by_email(params[:email])
      
      if @unsub.destroy
        flash[:success] = 'We successfully removed your unsubscribed status.'
      else
        flash[:error] = 'We are sorry. We had trouble removing your unsubscribed status. Please try again.'
      end

      if signed_in?
        redirect_to edit_user_path(current_user.permalink)
      else
        redirect_to root_path
      end
    else
      if signed_in?
        @unsub = Unsubscribe.find_by_user_id(current_user.id)
        if @unsub.destroy
          flash[:success] = 'We successfully removed your unsubscribed status.'
        else
          flash[:error] = 'We are sorry. We had trouble removing your unsubscribed status. Please try again.'
        end
        redirect_to edit_user_path(current_user.permalink)
      else
        flash[:notice] = 'Please sign in and then unsubscribe.'
        redirect_to root_path
      end
    end
  end
end