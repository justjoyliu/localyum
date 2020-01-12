class EventactivitiesController < ApplicationController
  before_filter :admin_user

  def create
    # @eventactivity = current_user.eventactivities.build(params[:eventactivity])
    # if @eventactivity.save
    #   flash[:success] = "Event created!"
    #   redirect_to root_url
    # else
    #   render 'static_pages/home'
    # end
  end

  def destroy
    @eventactivity.destroy
    redirect_to root_url
  end

end