class HosteventsController < ApplicationController
  before_filter :signed_in_user, only: [:create, :new, :new_evt_from_req, :create_evt_from_req, :propose_evt, :edit, :update, :editstep2, :edit_basic, :hostevent_open, :signup_requests, :hostevent_ratings, :destroy, :copy, :disassociate_menuitem, :hostevent_cancel, :send_invitation, :send_guestlist_to_host]
  before_filter :active_user, only: [:create, :new, :new_evt_from_req, :create_evt_from_req, :propose_evt, :edit, :update, :editstep2, :edit_basic, :hostevent_open, :signup_requests, :hostevent_ratings, :destroy, :copy, :disassociate_menuitem, :hostevent_cancel, :send_guestlist_to_host]
  before_filter :correct_user,   only: [:hostevent_open, :signup_requests, :hostevent_ratings, :destroy, :hostevent_cancel, :send_guestlist_to_host]
  before_filter :host_or_chef, only: [:edit, :update, :editstep2, :edit_basic,:disassociate_menuitem, :propose_evt, :chef_confirm_evt]
  before_filter :deleted_evt_check,   only: [:edit, :update, :editstep2, :edit_basic, :hostevent_open, :signup_requests, :hostevent_ratings, :destroy, :disassociate_menuitem, :hostevent_cancel]
  
  # display (index, show)
    def index
      # @hostevents = Hostevent.find_all_by_eventstatus("Open")

      # adding search
      @today_date = Time.new.to_date
      @today_hour = Time.new.strftime("%H").to_i
      @today_datetime = DateTime.new(@today_date.year, @today_date.month, @today_date.day, @today_hour)
      @metro_area = params[:metroarea] 

      if !params.has_key?(:hostevent) 
        @upcomingevts = Hostevent.where("eventstatus = ? AND (mealstarttime - INTERVAL (COALESCE(mustbookhoursinadvance, 0)) HOUR  )> ?", "Open", @today_datetime)
        @selected_cuisine_id = "N"
        @selected_charity_id = "N"
      else
        if params[:hostevent][:eventcategory_id].to_s == "N" and params[:hostevent][:charitypolicy_id].to_s == "N"
          @upcomingevts = Hostevent.where("eventstatus = ? AND (mealstarttime - INTERVAL (COALESCE(mustbookhoursinadvance, 0)) HOUR  )> ?", "Open", @today_datetime)
        elsif params[:hostevent][:eventcategory_id] == "N"
          if params[:hostevent][:charitypolicy_id] == "0"
            @upcomingevts = Hostevent.where("eventstatus = ? AND (mealstarttime - INTERVAL (COALESCE(mustbookhoursinadvance, 0)) HOUR  )> ? and charitypolicy_id is not null", "Open", @today_datetime)
          else
            @upcomingevts = Hostevent.where("eventstatus = ? AND (mealstarttime - INTERVAL (COALESCE(mustbookhoursinadvance, 0)) HOUR  )> ? and charitypolicy_id = ?", "Open", @today_datetime, params[:hostevent][:charitypolicy_id].to_s)
          end
        elsif params[:hostevent][:charitypolicy_id] == "N"
          @upcomingevts = Hostevent.where("eventstatus = ? AND (mealstarttime - INTERVAL (COALESCE(mustbookhoursinadvance, 0)) HOUR  )> ? and eventcategory_id = ?", "Open", @today_datetime, params[:hostevent][:eventcategory_id].to_s)
        else
          if params[:hostevent][:charitypolicy_id] == "0"
            @upcomingevts = Hostevent.where("eventstatus = ? AND (mealstarttime - INTERVAL (COALESCE(mustbookhoursinadvance, 0)) HOUR  )> ? and eventcategory_id = ? and charitypolicy_id is not null", "Open", @today_datetime, params[:hostevent][:eventcategory_id].to_s)
          else
            @upcomingevts = Hostevent.where("eventstatus = ? AND (mealstarttime - INTERVAL (COALESCE(mustbookhoursinadvance, 0)) HOUR  )> ? and eventcategory_id = ? and charitypolicy_id = ?", "Open", @today_datetime, params[:hostevent][:eventcategory_id].to_s, params[:hostevent][:charitypolicy_id].to_s)
          end
        end
        @selected_cuisine_id = params[:hostevent][:eventcategory_id]
        @selected_charity_id = params[:hostevent][:charitypolicy_id]
      end
     
      @hostevents = @upcomingevts.joins(:addressuser).where("metroarea = ?", params[:metroarea]).order(:mealstarttime)
      @hosts = User.joins(:addressusers).where("metroarea = ? and avatar_file_name is not null", params[:metroarea])
      
      @cuisine = @hostevents.count(:all, :group => 'eventcategory_id')
      @cuisine_select = {"All Cuisine Types" => ["N", @hostevents.count]}

      @charity = @hostevents.count(:all, :group => 'charitypolicy_id')
      @charity_select = {"No Charity Filter" => ["N", @hostevents.count], "Only Charity Events" => [0, @hostevents.where("charitypolicy_id is not null").count]}

      # @charity_select = {"All States"}
      @cuisine.each do |c|
        @cuisine_select.merge!(Eventcategory.find(c[0].to_s).categorytype => [c[0], c[1]])
      end

      @charity.each do |ch|
        unless ch[0].nil?
          @charity_select.merge!(Charitypolicy.find(ch[0].to_s).charityname => [ch[0], ch[1]])
        end
      end

      unless signed_in_store_location?
        # flash[:notice] = "Create a Local Yum account or Log In above to request seats for any event."
      end
    end

    def show
      @hostevent = Hostevent.find_by_permalink(params[:permalink])
      @copyevt = Hostevent.new

      if !@hostevent.nil? and (@hostevent.eventstatus == "Open" or (signed_in? and (@hostevent.user_id == current_user.id or @hostevent.chef_id == current_user.id)))
        @chef = User.find(@hostevent.user_id)
        @donation = (@hostevent.host_charity_cents.to_i + @hostevent.ly_charity_cents.to_i).to_f/100.00
        
        @sharing_title = @hostevent.event_name
        # @chef.name + "'s " + @hostevent.event_name + " looks delicious, plus you can look forward to meeting the chef and other foodies.", 
        # :description => "Exploring a new dining experience at " + @chef.name + "'s " + @hostevent.event_name + ".",

        if @hostevent.eventphotos.count == 0
          set_meta_tags :og => {
            :title    => @sharing_title,
            :description => "Leave every event not only with a full stomach, but also with a great social experience!",
            :type     => "article",
            :url      => hostevent_path(@hostevent.permalink),
            :image    => @chef.avatar.url(:medium)
          }
        else
          set_meta_tags :og => {
            :title    => @sharing_title,
            :description => "Leave every event not only with a full stomach, but also with a great social experience!",
            :type     => "article",
            :url      => hostevent_path(@hostevent.permalink),
            :image    => @hostevent.eventphotos.first.eventpic.url(:index_search)
          }
        end

        @json = @hostevent.addressuser.to_gmaps4rails
        @venue_prox = @hostevent.addressuser.gmaps_circle
        # in view <%= gmaps4rails(@json) %>
        @comment = @hostevent.messages.where("public_flag = ?", 1).group("messagechain_id", "order_id", "message_content", "sender_id").sort{|a,b| b[:messagechain_id] <=> a[:messagechain_id]}
      end

      if signed_in? and !@hostevent.nil?
        @user_signup = Signup.where("user_id = ? AND hostevent_id = ?", current_user.id, @hostevent.id).first
        @messagechain = Messagechain.new
        @messages = @messagechain.messages.build()

        @rating_msg_c = Messagechain.new
        @ratings_msg = @rating_msg_c.messages.build

        @msg_have = @hostevent.messages.where("receiver_id = ? and receiver_read = 0 and public_flag = 1", current_user.id)
        @msg_have.each do |m|
            m.update_attribute(:receiver_read, true)
        end
        # @messages = Message.new
      else
        signed_in_store_location?
        # flash[:notice] = "Create a Local Yum account or Log In above to request seats for this event."
      end

      @people_attending = @hostevent.signups.where("confirmation_status = ?", "Attending").sum(:guest_count)
    end

  # event new, create, copy, destroy
    def new
      # unless signed_in?
      #   flash[:notice] = 'Please sign in or sign up before creating an event.'
      #   redirect_to root_url
      # end
      @hostevent = Hostevent.new
      @addressuser = Addressuser.new
    end

    def new_evt_from_req
      @req = Recipereq.find_by_permalink(params[:permalink])
      if @req.chef_id == current_user.id
        @hostevent = Hostevent.new
      else
        redirect_to recipereqs_path      
      end
    end

    def create_evt_from_req
      @req = Recipereq.find_by_permalink(params[:permalink])

      if params[:hostevent][:startdate].to_s.empty? or params[:hostevent][:price].to_s.empty?
        flash[:error] = 'Please fill in proposed date, time, cuisine type, and price before clicking "Propose Event"'
        redirect_to new_evt_from_req_path(@req.permalink)
      elsif @req.chef_id == current_user.id
        params[:hostevent].parse_time_select!(:mealstarttime)
        @host = User.find(@req.user_id)

        @hostevent = @host.hostevents_as_host.build(params[:hostevent])
        
        if params[:hostevent].has_key?(:mealstarttime)
          @mealstart = DateTime.new(@hostevent.startdate.year, @hostevent.startdate.month, @hostevent.startdate.day, 
                  @hostevent.mealstarttime.hour, @hostevent.mealstarttime.min)
          @hostevent.update_attribute(:mealstarttime, @mealstart.to_s(:db))
        end 

        @hostevent.update_attribute(:chef_id, current_user.id)
        @req.update_attribute(:hostevent_id, @hostevent.id)
        
        recipebox_menuitem = Menuitem.find(@req.menuitem_id)
        @hostevent.menuitems << recipebox_menuitem

        @hostevent.save

        flash[:success] = 'Finish the proposal by adding a menu and clicking "Send Proposal"'
        redirect_to edit_hostevent_path(@hostevent.permalink)
      else
        redirect_to recipereqs_path      
      end
    end

    def propose_evt
      UserMailer.to_host_evt_proposal_from_chef(@hostevent).deliver
      flash[:success] = 'The host has been notified of the proposed event.'
      redirect_to hostevent_path(@hostevent.permalink)
    end

    def chef_confirm_evt
      if @hostevent.eventstatus != 'Open'
        flash[:error] = 'The host first need to open the event in order for you to confirm this event to be ready for sign up.'
      elsif @hostevent.evt_open?
        flash[:success] = 'The event is ready for signup already. No additional confirmation is needed.'
      elsif @hostevent.chef_id != current_user.id
        flash[:error] = 'Please log in as the chef to confirm this event.'
      else
        @hostevent.update_attribute(:chef_confirm, 1)
        UserMailer.to_host_evt_chef_confirmed(@hostevent).deliver
        flash[:success] = 'The host has been notified that the event is ready for signup.'
      end

      redirect_to hostevent_path(@hostevent.permalink)
    end

    def create
      
      if !params[:hostevent].has_key?(:startdate)
        flash[:error] = "Please choose event date"
        redirect_to new_hostevent_path
      elsif !params[:hostevent].has_key?(:event_name)
        flash[:error] = "You must have a name for the event"
        redirect_to new_hostevent_path
      elsif !Hostevent.where("event_name = ? and startdate = ?", params[:hostevent][:event_name], params[:hostevent][:startdate]).empty?
        same_evt = Hostevent.where("event_name = ? and startdate = ?", params[:hostevent][:event_name], params[:hostevent][:startdate]).first
        flash[:error] = "There is already an event with the same name on the same day. You cannot create the same events on the same day."
        redirect_to same_evt
      else
        params[:hostevent].parse_time_select!(:mealstarttime)
        @hostevent = current_user.hostevents_as_host.build(params[:hostevent])
        
        # 2.times { @hostevent.eventphotos.build }
        #@eventphotos = hostevent.eventphotos.build(params[:eventphoto])
        
        if params[:hostevent].has_key?(:mealstarttime)
          @mealstart = DateTime.new(@hostevent.startdate.year, @hostevent.startdate.month, @hostevent.startdate.day, 
                  @hostevent.mealstarttime.hour, @hostevent.mealstarttime.min)
          @hostevent.update_attribute(:mealstarttime, @mealstart.to_s(:db))
        end 

        @hostevent.update_attribute(:chef_id, current_user.id)
        @hostevent.save
        # if @hostevent.save
          # flash[:success] = "Event was created! All that's left is add menu items, event name, description, photo and address (visible only to confirmed guests) before you are ready to open for sign up!!"
          #@hostevent.mealstarttime.to_formatted_s(:long_ordinal)        
        # else
        #   render 'static_pages/home'
        # end
        flash[:success] = "Congratulations, your event has been created! All that is left to do is add your menu and some event details before you are ready to open for sign up!"
        redirect_to edit_hostevent_path(@hostevent.permalink)

      end
    end

    def copy
      @hostevent = Hostevent.find_by_permalink(params[:hostevent][:id])

      if current_user.id != @hostevent.user_id
        flash[:error] = "You can only copy the events that you have created."
        redirect_to hostevent_path(@hostevent.permalink)
      elsif !params[:hostevent].has_key?(:startdate)
        flash[:error] = "You must choose a date in the future for your new event when you copy this event."
        redirect_to hostevent_path(@hostevent.permalink)
      elsif params[:hostevent][:startdate].to_date.past?
        flash[:error] = "You must choose a date in the future for your new event when you copy this event."
        redirect_to hostevent_path(@hostevent.permalink)
      else
        params[:hostevent].parse_time_select!(:mealstarttime)

        # @new_evt = @hostevent.dup    
          # @new_evt.update_attribute(:startdate, params[:hostevent][:startdate])
          # @new_evt.update_attribute(:mealstarttime, params[:hostevent][:mealstarttime])
          # @new_evt.update_attribute(:eventstatus, 'Setup')
          # @new_evt.update_attribute(:transfer_id, nil)
          # @new_evt.update_attribute(:payout_method, nil)
          # @new_evt.update_attribute(:address_to_send_payout_id, nil)
          # @new_evt.update_attribute(:payout_status, nil)
          # @new_evt.update_attribute(:payout_date, nil)
          # @new_evt.update_attribute(:host_net_earnings_cents, 0)
          # @new_evt.update_attribute(:host_charity_cents, nil)
          # @new_evt.update_attribute(:ly_charity_cents, nil)
          # @new_evt.update_attribute(:ly_net_host_fee, nil)
          # @new_evt.update_attribute(:payout_non_ach_info, nil)
          # @new_evt.update_attribute(:penalty_cents, nil)
        
        if @hostevent.confirmability? 
          conf=1
        else 
          conf=0
        end

        if @hostevent.guestallowforprep? 
          guest_allow=1
        else 
          guest_allow=0
        end

        if @hostevent.clean_optin? 
          cloi=1
        else 
          cloi=0
        end

        if @hostevent.local_ingredients_optin? 
          lioi=1
        else 
          lioi=0
        end

        if @hostevent.tip_included? 
          tip=1
        else 
          tip=0
        end

        if @hostevent.age_21plus? 
          age=1
        else 
          age=0
        end

        # @new_evt = Hostevent.create!(attributes_for_new)
        @new_evt = current_user.hostevents_as_host.build(
          :startdate => params[:hostevent][:startdate],
          :mealstarttime => params[:hostevent][:mealstarttime], 
          :eventcategory_id => @hostevent.eventcategory_id,
          :price => @hostevent.price,
          :cancellationpolicy_id => @hostevent.cancellationpolicy_id,
          # :confirmability => @hostevent.confirmability,
          :confirmability => conf,
          :event_name => @hostevent.event_name,

          :charitypolicy_id => @hostevent.charitypolicy_id,
          :mustbookhoursinadvance => @hostevent.mustbookhoursinadvance,
          :maxguests => @hostevent.maxguests,
          :bestwaytocontact => @hostevent.bestwaytocontact,
          :discussiontopics => @hostevent.discussiontopics,
          :extracomments => @hostevent.extracomments,
          :guestallowforprep => guest_allow,
          :requestsforguests => @hostevent.requestsforguests,
          :timestartprep => @hostevent.timestartprep,
          :addressuser_id => @hostevent.addressuser_id,
          :eventactivity_ids => @hostevent.eventactivity_ids,
          :menuitem_ids => @hostevent.menuitem_ids,
          :clean_optin => cloi,
          :local_ingredients_optin => lioi, 
          :age_21plus => age, 
          :tip_included => tip, 
          :chef_id => @hostevent.chef_id
          # :user_id => current_user.id
          )
   
        # @new_evt.save
        # @new_evt.eventactivities = @hostevent.eventactivities
        # @new_evt.menuitems = @hostevent.menuitems
        # @new_evt.eventphotos = @hostevent.eventphotos there was an error when included copy photos that prevented saving

        @mealstart = DateTime.new(@new_evt.startdate.year, @new_evt.startdate.month, @new_evt.startdate.day, 
                  @new_evt.mealstarttime.hour, @new_evt.mealstarttime.min)

        @new_evt.update_attribute(:mealstarttime, @mealstart.to_s(:db))

        @new_evt.save

        flash[:success] = "Congratulations, your event has been created! All that is left to do is add your menu and some event details before you are ready to open for sign up!"
        # flash[:error] = 'year ' + params[:hostevent][:startdate][0..3] + ', month '+ params[:hostevent][:startdate][5..6] + ', date ' + params[:hostevent][:startdate][8..9] + ': overall ' + params[:hostevent][:startdate]

        if @new_evt.addressuser.line1.nil?
          flash[:warning] = "Remember to set a new location. The event you copied from had a location that is no longer in your address book."
        end
        redirect_to edit_hostevent_path(@new_evt.permalink)
      end
    end

    def destroy
      if @hostevent.event_start_date_upcoming?
        flash[:warning] = 'You can only delete events that is in the past.'
        redirect_to show_mypastevents_path
      elsif @hostevent.signups.where("confirmation_status = ?", "Confirmed").count > 0
        flash[:error] = 'You cannot delete an event that someone attended.'
      else
        # @hostevent.destroy
        @hostevent.update_attribute(:eventstatus, "Deleted")
        flash[:warning] = 'The event has been deleted from our system.'
        redirect_to show_mypastevents_path
      end  
    end

  # edit, update
    def edit_basic
      if !@hostevent.event_start_date_upcoming?
        flash[:warning] = "Your event has already passed. You can no longer edit your event. Foodies visiting this event will see the following ..."
        redirect_to hostevent_path(@hostevent.permalink)
      elsif @hostevent.eventstatus == "Open"
        flash[:error] = 'You cannot edit event name, cuisine theme, time, price, and policies after you have opened the event. In order to edit these, you would need to cancel the event (which would decline all guest requests regardless of your previous confirmation).'
        redirect_to signup_requests_path(@hostevent.permalink)
      else
        @addressuser = Addressuser.new
      end
    end

    def edit
      if !@hostevent.event_start_date_upcoming?
        flash[:warning] = "Your event has already passed. You can no longer edit your event. Foodies visiting this event will see the following ..."
        redirect_to hostevent_path(@hostevent.permalink)
      # modified on 3/19/2014 so people can edit menu once opened
      # elsif @hostevent.eventstatus == "Open"
      #   flash[:error] = 'You cannot edit event details after you have opened the event. In order to edit, you would need to cancel the event (which would decline all guest requests regardless of your previous confirmation).'
      #   redirect_to signup_requests_path(@hostevent.permalink)
      else
        @menuitem = Menuitem.new(:hostevent_ids => @hostevent.id)
        if @hostevent.menuitem_ids.empty?
          @recipebox_menuitem_notused = Menuitem.order("name").find_all_by_user_id(current_user.id)
        else
          @recipebox_menuitem_notused = Menuitem.order("name").where("user_id = (?) AND id not in (?)", current_user.id, @hostevent.menuitem_ids)
        end
      end
    end

    def disassociate_menuitem
      # hostevent = Hostevent.find(params[:id])
      menuitem = @hostevent.menuitems.find_by_permalink(params[:menu])

      @hostevent.menuitems.delete(menuitem)
      redirect_to edit_hostevent_path(@hostevent.permalink)
    end

    def editstep2
      if !@hostevent.event_start_date_upcoming?
        flash[:warning] = "Your event has already passed. You can no longer edit your event. Foodies visiting this event will see the following ..."
        redirect_to hostevent_path(@hostevent.permalink)
      # modified on 3/19/2014 so people can edit menu once opened
      # elsif @hostevent.eventstatus == "Open"
      #   flash[:error] = 'You cannot edit event details after you have opened the event. In order to edit, you would need to cancel the event (which would decline all guest requests regardless of your previous confirmation).'
      #   redirect_to signup_requests_path(@hostevent.permalink)
      else
        @addressuser = Addressuser.new
        respond_to do |format|
          format.html
          format.js
        end
      end
    end

    def update
      have_same_event = 0
      step2_count = 0
      #@hostevent = Hostevent.find(params[:id])

      #####not tested yet ... example from http://railscasts.com/episodes/17-habtm-checkboxes
      #params[:hostevent_id][:eventactivities_ids] ||= []
      if params.has_key?(:hostevent)
        # basic info
          if params[:hostevent].has_key?(:startdate)
            if !Hostevent.where("event_name = ? and startdate = ? and id <> ?", params[:hostevent][:startdate], params[:hostevent][:startdate], @hostevent.id).empty?
              # same_evt = Hostevent.where("event_name = ? and startdate = ?", params[:hostevent][:startdate], params[:hostevent][:startdate]).first
              have_same_event = 1
            else
              if @hostevent.update_attribute(:startdate, params[:hostevent][:startdate])
                  flash[:success] = 'Event details updated.'
              end

              unless params[:hostevent].has_key?("mealstarttime(5i)")
                @mealstart = DateTime.new(@hostevent.startdate.year, @hostevent.startdate.month, @hostevent.startdate.day, @hostevent.mealstarttime.hour, @hostevent.mealstarttime.min)
                @hostevent.update_attribute(:mealstarttime, @mealstart.to_s(:db))
              end 
            end
          end

          if params[:hostevent].has_key?("mealstarttime(5i)")
            @parcedtime = params[:hostevent].parse_time_select!(:mealstarttime)

            @mealstart = DateTime.new(@hostevent.startdate.year, @hostevent.startdate.month, @hostevent.startdate.day, 
                  @parcedtime[:mealstarttime].hour, @parcedtime[:mealstarttime].min)
            @hostevent.update_attribute(:mealstarttime, @mealstart.to_s(:db))
          end
   
          if params[:hostevent].has_key?(:eventcategory_id)
            if @hostevent.update_attribute(:eventcategory_id, params[:hostevent][:eventcategory_id])
              # update_attribute(params[:hostevent])
                flash[:success] = 'Event details updated.'
                #redirect_to :action => 'show', :id => @hostevent
            end 
          end

          if params[:hostevent].has_key?(:clean_optin)
            if @hostevent.update_attribute(:clean_optin, params[:hostevent][:clean_optin])
              # update_attribute(params[:hostevent])
                flash[:success] = 'Event details updated.'
                #redirect_to :action => 'show', :id => @hostevent
            end 
            step2_count += 1
          end

          if params[:hostevent].has_key?(:local_ingredients_optin)
            if @hostevent.update_attribute(:local_ingredients_optin, params[:hostevent][:local_ingredients_optin])
              # update_attribute(params[:hostevent])
                flash[:success] = 'Event details updated.'
                #redirect_to :action => 'show', :id => @hostevent
            end 
            step2_count += 1
          end

          if params[:hostevent].has_key?(:tip_included)
            if @hostevent.update_attribute(:tip_included, params[:hostevent][:tip_included])
              # update_attribute(params[:hostevent])
                flash[:success] = 'Event details updated.'
                #redirect_to :action => 'show', :id => @hostevent
            end 
            step2_count += 1
          end

          if params[:hostevent].has_key?(:age_21plus)
            if @hostevent.update_attribute(:age_21plus, params[:hostevent][:age_21plus])
              # update_attribute(params[:hostevent])
                flash[:success] = 'Event details updated.'
                #redirect_to :action => 'show', :id => @hostevent
            end 
            step2_count += 1
          end

          if params[:hostevent].has_key?(:price)
            if @hostevent.update_attribute(:price, params[:hostevent][:price])
              # update_attribute(params[:hostevent])
                flash[:success] = 'Event details updated.'
                #redirect_to :action => 'show', :id => @hostevent
            end 
          end
          
          if params[:hostevent].has_key?(:charitypolicy_id)
            if @hostevent.update_attribute(:charitypolicy_id, params[:hostevent][:charitypolicy_id])
              # update_attribute(params[:hostevent])
                flash[:success] = 'Event details updated.'
                #redirect_to :action => 'show', :id => @hostevent
            end 
          end

          if params[:hostevent].has_key?(:cancellationpolicy_id)
            if @hostevent.update_attribute(:cancellationpolicy_id, params[:hostevent][:cancellationpolicy_id])
              # update_attribute(params[:hostevent])
                flash[:success] = 'Event details updated.'
                #redirect_to :action => 'show', :id => @hostevent
            end 
          end


        # if !params[:hostevent][:bestwaytocontact].empty?
        if params[:hostevent].has_key?(:bestwaytocontact)
          if @hostevent.update_attribute(:bestwaytocontact, params[:hostevent][:bestwaytocontact])
            # update_attribute(params[:hostevent])
              flash[:success] = 'Event details updated.'
              #redirect_to :action => 'show', :id => @hostevent
          end 
          step2_count += 1
        end

        # if !params[:hostevent][:requestsforguests].empty?
        if params[:hostevent].has_key?(:requestsforguests)
          if @hostevent.update_attribute(:requestsforguests, params[:hostevent][:requestsforguests])
            # update_attribute(params[:hostevent])
              flash[:success] = 'Event details updated.'
              #redirect_to :action => 'show', :id => @hostevent
          end 
          step2_count += 1
        end
        
        # if !params[:hostevent][:extracomments].empty?
        if params[:hostevent].has_key?(:extracomments)
          if @hostevent.update_attribute(:extracomments, params[:hostevent][:extracomments])
            # update_attribute(params[:hostevent])
              flash[:success] = 'Event details updated.'
              #redirect_to :action => 'show', :id => @hostevent
          end 
          step2_count += 1
        end

        # if !params[:hostevent][:discussiontopics].empty?
        if params[:hostevent].has_key?(:discussiontopics)
          if @hostevent.update_attribute(:discussiontopics, params[:hostevent][:discussiontopics])
            # update_attribute(params[:hostevent])
              flash[:success] = 'Event details updated.'
              #redirect_to :action => 'show', :id => @hostevent
          end 
          step2_count += 1
        end
        
        # if !params[:hostevent][:addressuser_id].empty?
        if params[:hostevent].has_key?(:addressuser_id)
          if @hostevent.update_attribute(:addressuser_id, params[:hostevent][:addressuser_id])
            # update_attribute(params[:hostevent])
              flash[:success] = 'Event details updated.'
              #redirect_to :action => 'show', :id => @hostevent
          end 
          step2_count += 1
        end

        # if !params[:hostevent][:event_name].empty?
        if params[:hostevent].has_key?(:event_name)
          if !Hostevent.where("event_name = ? and startdate = ? and id <> ?", params[:hostevent][:event_name], @hostevent.startdate, @hostevent.id).empty?
              # same_evt = Hostevent.where("event_name = ? and startdate = ?", params[:hostevent][:event_name], @hostevent.startdate).first
              # flash[:error] = "There is already an event with the same name on the same day. You cannot create the same events on the same day."
              # redirect_to same_evt
              have_same_event = 1
          else
            if @hostevent.update_attribute(:event_name, params[:hostevent][:event_name])
              # update_attribute(params[:hostevent])
                flash[:success] = 'Event details updated.'
                #redirect_to :action => 'show', :id => @hostevent
            end 
          end
        end

        # if !params[:hostevent][:mustbookhoursinadvance].empty?
        if params[:hostevent].has_key?(:mustbookhoursinadvance)
          if @hostevent.update_attribute(:mustbookhoursinadvance, params[:hostevent][:mustbookhoursinadvance])
            # update_attribute(params[:hostevent])
              flash[:success] = 'Event details updated.'
              #redirect_to :action => 'show', :id => @hostevent
          end 
        end

        # if !params[:hostevent][:maxguests].empty?
        if params[:hostevent].has_key?(:maxguests)
          if @hostevent.update_attribute(:maxguests, params[:hostevent][:maxguests])
            # update_attribute(params[:hostevent])
              flash[:success] = 'Event details updated.'
              #redirect_to :action => 'show', :id => @hostevent
          end 
        end

        # if !params[:hostevent][:confirmability].empty?
        if params[:hostevent].has_key?(:confirmability)
          if @hostevent.update_attribute(:confirmability, params[:hostevent][:confirmability])
            # update_attribute(params[:hostevent])
              flash[:success] = 'Event details updated.'
              #redirect_to :action => 'show', :id => @hostevent
          end 
        end

        if params[:hostevent].has_key?(:chef_comment) and current_user.id == @hostevent.chef_id
          if @hostevent.update_attribute(:chef_comment, params[:hostevent][:chef_comment])
              flash[:success] = 'Event details updated.'
          end 
        end
      end

      if !@hostevent.hostevent_status_could_be_complete? && @hostevent.eventstatus == "Open" && @hostevent.event_start_date_upcoming?
        @hostevent.update_attribute(:eventstatus, "Setup")
      end

      if params.has_key?(:menuitem)
        #@menuitem = @hostevent.build_menuitem(params[:menuitem])
        @hostevent.menuitem.build(params[:menuitem])
        #@hostevent.hostevents_menuitems.find_or_create_by_hostevent_id ({ @hostevent.id, :menuitem_id => @menuitem.id})
        redirect_to edit_hostevent_path(@hostevent.permalink)
      elsif params.has_key?(:recipebox_menuitem_id)
        if(!@hostevent.menuitems.exists?(params[:recipebox_menuitem_id]))
          recipebox_menuitem = Menuitem.find(params[:recipebox_menuitem_id])
          @hostevent.menuitems << recipebox_menuitem
        end
        redirect_to edit_hostevent_path(@hostevent.permalink)
      elsif have_same_event > 0
        flash[:error] = "There is already an event with the same name on the same day. We could not edit the name or date of the event as your wished."
        flash[:success] = 'All edits were made except name and date because there is already an event on that date with the same name'
        # redirect_to same_evt
        redirect_to edit_basic_path(@hostevent.permalink)
      elsif params.has_key?(:open_event)
        if !@hostevent.event_start_date_upcoming?
          flash[:warning] = "Your event has already passed. Foodies visiting this event will see the following ..."
          redirect_to hostevent_path(@hostevent.permalink)
        else
          # @hostevent.update_attribute(:eventstatus, "Open")
          @hostevent.hostevent_reopen
          redirect_to hostevent_path(@hostevent.permalink)
        end
      elsif params.has_key?(:cancel_event)
        if !@hostevent.event_start_date_upcoming?
          flash[:warning] = "Your event has already passed. Foodies visiting this event will see the following ..."
          redirect_to hostevent_path(@hostevent.permalink)
        else
          # @hostevent.update_attribute(:eventstatus, "Cancelled")
          @hostevent.hostevent_cancellation
          redirect_to edit_hostevent_path(@hostevent.permalink)
        end
      elsif @hostevent.eventstatus == "Open"
        redirect_to signup_requests_path(@hostevent.permalink)
      elsif params.has_key?(:return_edit_page)
        if params[:return_edit_page] == "basic"
          redirect_to edit_hostevent_path(@hostevent.permalink)
        elsif params[:return_edit_page] == "details"
          redirect_to addphoto_to_event_path(@hostevent.permalink)
        else
          redirect_to edit_hostevent_path(@hostevent.permalink)
        end
      # elsif !@hostevent.hostevent_step1?
      elsif params.has_key?(:menuitem) || params.has_key?(:recipebox_menuitem_id)
        redirect_to edit_hostevent_path(@hostevent.permalink)
      # elsif !@hostevent.hostevent_step2? 
      elsif params.has_key?(:hostevent) 
        redirect_to hostevent_path(@hostevent.permalink) 
      else 
        redirect_to addphoto_to_event_path(@hostevent.permalink)
      end
    end

  # event maintenance (open, cancel, signup requests, ratings)
    def hostevent_open
      # @hostevent = Hostevent.find(params[:id])
      if !@hostevent.event_start_date_upcoming?
        flash[:warning] = "Your event has already passed. Foodies visiting this event will see the following ..."
        redirect_to hostevent_path(@hostevent.permalink)
      else
        # @hostevent.update_attribute(:eventstatus, "Open")
        @hostevent.hostevent_reopen
        
        if @hostevent.user_id != @hostevent.chef_id
          UserMailer.to_chef_evt_approval_req(@hostevent).deliver
          flash[:success] = 'The chef has been notified to review the event. Once the chef confirms, the event will be ready for sign up.'
        end

        redirect_to hostevent_path(@hostevent.permalink)
      end
    end

    def hostevent_cancel
      # @hostevent = Hostevent.find(params[:id])
      if !@hostevent.event_start_date_upcoming?
        flash[:warning] = "Your event has already passed. Foodies visiting this event will see the following ..."
        redirect_to hostevent_path(@hostevent.permalink)
      else
        # @hostevent.update_attribute(:eventstatus, "Cancelled")
        @hostevent.hostevent_cancellation
        redirect_to edit_hostevent_path(@hostevent.permalink)
      end
    end

    def signup_requests
      if @hostevent.eventstatus != "Open"
        flash[:warning] = 'Your event must be open in order to manage sign up requests'
        redirect_to edit_hostevent_path(@hostevent.permalink)
      end

      if !@hostevent.event_start_date_upcoming?
        flash[:warning] = "Your event has already passed. You can no longer manage sign ups."
        redirect_to hostevent_ratings_path(@hostevent.permalink)
      end

      @evt_signups = @hostevent.signups.where("confirmation_status != ? and confirmation_status != ? and confirmation_status != ?", "Waitlist", "Withdrawn", "Declined").order("updated_at DESC")
      @evt_waitlist = @hostevent.signups.where("confirmation_status = ?", "Waitlist").order("updated_at").paginate(:per_page => 5, :page => params[:page])
      @evt_withdrawn = @hostevent.signups.where("confirmation_status = ? or confirmation_status = ?", "Withdrawn", "Declined").order("updated_at")

      @confirmed = @evt_signups.where("confirmation_status = ?", "Confirmed")
      @paid = @evt_signups.where("confirmation_status = ?", "Attending")
      @waiting = @evt_signups.where("confirmation_status = ? and confirmation_host = ?", "Waiting", "0")

      @paid_communal = @paid.where("own_group_flag = 0")
      @own_table = @paid.where("own_group_flag = 1")
    end

    def hostevent_ratings
      if @hostevent.event_start_date_upcoming?
        flash[:warning] = "You can only view ratings once this event has passed"
        redirect_to hostevent_path(@hostevent.permalink)
      elsif @hostevent.eventstatus != "Open" || @hostevent.event_attend_count < 1
        flash[:warning] = "No one attended this event. You cannot view the ratings or guests."
        redirect_to hostevent_path(@hostevent.permalink)
      end

      # @attended = @hostevent.signups.where("confirmation_status = ?", "Attending")
      @attended = @hostevent.guests_attending
      @rating_cmts = @hostevent.messages.where("signup_id is not null").order("updated_at DESC")

      @messagechain = Messagechain.new
      @cmt = @messagechain.messages.build
    end

  # promote event
    def send_invitation
      if current_user.nil?
        flash[:error] = 'Please sign in before we can send invitations for an event on your behalf.'
        redirect_to root_path
      else
        @evt = Hostevent.find_by_permalink(params[:id])

        if @evt.nil? or @evt.eventstatus != "Open"
          flash[:error] = 'Unfortunately, this event has not opened for sign up yet. We can only send invitations for events that are open.'
        else
          @emails = params[:hostevent][:invite_guest_emails].split(/,\s/) 
          email_list = check_unsubscribed(@emails) #return [send_invite_to, unsub_emails]

          if email_list[0].empty?
            flash[:warning] = 'We have emailed the event invitations on your behalf with the exception of those who have requested in the past to be removed from our marketing (' + email_list[1].chop.chop + ')'
          elsif email_list[1].empty?
            # UserMailer.invitation(@evt, params[:hostevent][:invite_guest_emails], current_user.email, current_user.name).deliver
            UserMailer.invitation(@evt, email_list[0].chop.chop, current_user.email, current_user.name).deliver
            flash[:success] = 'We have emailed all the event invitations on your behalf.' #+ ' -- emails: ' + @emails.to_s + ' -- do not: '+ email_list[1].to_s + ' -- send to: ' + email_list[0].to_s
          else
            UserMailer.invitation(@evt, email_list[0].chop.chop, current_user.email, current_user.name).deliver
            flash[:warning] = 'We have emailed the event invitations on your behalf with the exception of those who have requested in the past to be removed from our marketing (' + email_list[1].chop.chop + ')'
          end
        end 
        redirect_to hostevent_path(@evt.permalink)
      end
    end

    def send_guestlist_to_host
      UserMailer.event_reminder_to_chef(@hostevent).deliver
      flash[:success] = 'We just sent you an email with the guest list for this event'
      redirect_to hostevent_path(@hostevent.permalink)
    end

  # reporting
    def calc_evt_earnings
      @evt_completed = Hostevent.where("eventstatus in ('Open') and mealstarttime < ? and host_net_earnings_cents = 0 and price > 0", (Date.today - 48.hours))
      updated_earnings = 0

      @evt_completed.each do |e|
        if e.signups.where("confirmation_status in ('Attending', 'Withdrawn')").count > 0
          unless e.signups.where("confirmation_status in ('Attending') and dispute_flag = 1").count > 0 
            e.event_host_earnings
            updated_earnings += 1
          end
        end 
      end

      flash[:success] = @evt_completed.count.to_s + ' events looked up, ' + updated_earnings.to_s + ' event earnings updated.'
      redirect_to root_path
    end

  private

    def correct_user
      @hostevent = current_user.hostevents_as_host.find_by_permalink(params[:permalink])
      if @hostevent.nil?
        flash[:error] = 'Sorry, but you must be the event host in order to access page/function' 
        redirect_to(hostevent_path(Hostevent.find_by_permalink(params[:permalink])))
      end
    end

    def deleted_evt_check
      if @hostevent.eventstatus.to_s == "Deleted"
        flash[:error] = 'This event has already been deleted. You can no longer access this function.'
        redirect_to show_mypastevents_path
      end
    end

    def host_or_chef
      @hostevent = Hostevent.find_by_permalink(params[:permalink])
      if @hostevent.nil?
        @req = Recipereq.find_by_permalink(params[:permalink])
        if @req.nil? or (@req.user_id != current_user.id and @req.chef_id != current_user.id)
          flash[:error] = 'Sorry, but you must be the event host or chef in order to access page/function' 
          redirect_to(hostevent_path(Hostevent.find_by_permalink(params[:permalink])))
        end
      else
        if @hostevent.user_id != current_user.id and @hostevent.chef_id != current_user.id
          flash[:error] = 'Sorry, but you must be the event host or chef in order to access page/function' 
          redirect_to(hostevent_path(Hostevent.find_by_permalink(params[:permalink])))
        end
      end
    end
end