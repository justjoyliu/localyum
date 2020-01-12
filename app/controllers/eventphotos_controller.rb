class EventphotosController < ApplicationController
  #before_filter :correct_user,   only: [:create, :edit, :update]
  before_filter :signed_in_user #, only: [:create, :new, :destroy]
  before_filter :correct_user

  def new
    @user_agent = UserAgent.parse(request.env["HTTP_USER_AGENT"])
    if @user_agent.browser == "Internet Explorer" and @user_agent.version.to_s.gsub(/\D/, '').to_i < 100
      flash[:warning] = 'Use Chrome or Mozilla Firefox for the ideal experience. Or upgrade to IE10+ for better photo upload function. Unfortunately, your browser does not support multiple photo uploads.'
      redirect_to addphoto_to_event_ie_path(@hostevent.permalink)
    # modified on 3/19/2014 so people can edit once opened
    # elsif @hostevent.eventstatus == "Open"
    #   flash[:error] = 'You cannot edit event details after you have opened the event. In order to edit, you would need to cancel the event (which would decline all guest requests regardless of your previous confirmation).'
    #   redirect_to signup_requests_path(@hostevent.permalink)
    # modified 3/23/2014 so people can add photos once event is over
    # elsif !@hostevent.event_start_date_upcoming?
    #   flash[:warning] = "Your event has already passed. Foodies visiting this event will see the following ..."
    #   redirect_to hostevent_path(@hostevent.permalink)
    else
      @eventphoto = Eventphoto.new
      if !@hostevent.hostevent_status_could_be_complete? && @hostevent.eventstatus == "Open"
        @hostevent.update_attribute(:eventstatus, "Setup")
      end
      @eventphoto_existing = @hostevent.eventphotos
    end
    # session[:return_to] = request.fullpath
  end

  def new_dumb
    # modified on 3/19/2014 so people can edit once opened
    # if @hostevent.eventstatus == "Open"
    #   flash[:error] = 'You cannot edit event details after you have opened the event. In order to edit, you would need to cancel the event (which would decline all guest requests regardless of your previous confirmation).'
    #   redirect_to signup_requests_path(@hostevent.permalink)
    # modified 3/23/2014 so people can add photos once event is over
    # if !@hostevent.event_start_date_upcoming?
    #   flash[:warning] = "Your event has already passed. Foodies visiting this event will see the following ..."
    #   redirect_to hostevent_path(@hostevent.permalink)
    # else
      @eventphoto = Eventphoto.new
      if !@hostevent.hostevent_status_could_be_complete? && @hostevent.eventstatus == "Open"
        @hostevent.update_attribute(:eventstatus, "Setup")
      end
      @eventphoto_existing = @hostevent.eventphotos
    # end
  end

  def create
    #@eventphoto = Eventphoto.new(params[:eventphoto])
    #@eventphoto = current_user.eventphotos.build(params[:eventphoto])
    # @hostevent = Hostevent.find_by_permalink(params[:permalink])
    @eventphoto = Eventphoto.create(params[:eventphoto])
    @eventphoto.update_attribute(:hostevent_id, @hostevent.id)

    @user_agent = UserAgent.parse(request.env["HTTP_USER_AGENT"])
    if @user_agent.browser == "Internet Explorer" and @user_agent.version.to_s.gsub(/\D/, '').to_i < 100
      flash[:warning] = 'Use Chrome or Mozilla Firefox for the ideal experience. Or upgrade to IE10+ for better photo upload function. Unfortunately, your browser does not support multiple photo uploads.'
      redirect_to addphoto_to_event_ie_path(@hostevent.permalink)
    end
  end

  def destroy
    Eventphoto.find(params[:id]).destroy
    flash[:success] = "Photo deleted"
    redirect_to addphoto_to_event_path(@hostevent.permalink)
  end

  
   private

     def correct_user
  #     @eventphoto = current_user.eventphotos.find_by_id(params[:id])
  #     redirect_to root_url if @eventphoto.nil?
        @hostevent = Hostevent.find_by_permalink(params[:permalink])
        if @hostevent.user_id != current_user.id and @hostevent.chef_id != current_user.id
            flash[:error] = 'Sorry, but you must be the event host or chef in order to access page' 
            redirect_to(hostevent_path(@hostevent.permalink))
        end
     end
end
