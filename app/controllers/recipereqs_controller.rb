class RecipereqsController < ApplicationController
  before_filter :signed_in_user
  before_filter :active_user
  before_filter :correct_user,   only: [:edit, :update]

  def index
    @host = Recipereq.where('user_id = ? and as_host_flag = 1', current_user.id).order('updated_at DESC')
    @chef_unanswered = Recipereq.where('chef_id = ? and req_status = 0 and as_host_flag = 1', current_user.id).order('updated_at DESC')
    @chef_answered = Recipereq.where('chef_id = ? and req_status in (-1, 1) and as_host_flag = 1', current_user.id).order('updated_at DESC')
    @host_req = Recipereq.where('user_id = ? and as_host_flag = 1', current_user.id).order('updated_at DESC')
  end
  
  # for hosts and yummers
    def create
      # @chef = User.find(params[:relationship][:followed_id])
      mi = Menuitem.find_by_permalink(params[:menuitem])
      
      if mi.user_id == current_user.id
        flash[:error] = 'You cannot request your own recipe'
        redirect_to menuitem_path(params[:menuitem])
      elsif params.has_key?(:as_host_flag)
        new_req_as_host = current_user.recipereqs.build(:menuitem_id => mi.id, :chef_id => mi.user_id, :as_host_flag => params[:as_host_flag])
          
          if new_req_as_host.save
            flash[:success] = 'Submit the completed form for the event you are interested in hosting that features this item. We will forward the message to the chef and email you when he/she replies.'
            redirect_to edit_recipereq_path(new_req_as_host.permalink)
          else
            flash[:error] = 'Sorry, we encountered an error. Please try again. If this error persists, please contact us with the details.'
            if params.has_key?(:page_return)
              if params[:page_return] == 'Favorite Chefs'
                redirect_to following_path
              else
                redirect_to user_path(User.find(mi.user_id).permalink)
              end
            else
              redirect_to menuitem_path(params[:menuitem])
            end
          end
      else
        req = current_user.recipereqs.find_by_menuitem_id(mi.id)

        if req.nil?
          new_req = current_user.recipereqs.build(:menuitem_id => mi.id, :chef_id => mi.user_id)
          
          if new_req.save
            flash[:success] = 'Thanks for requesting this recipe. We will notify the chef of this request. We will message you when the chef features this recipe.'
            # flash[:error] = new_req.to_s
          else
            flash[:error] = 'Sorry, we encountered an error. Please try again. If this error persists, please contact us with the details.'
          end
        else
          flash[:warning] = 'Your request was already sent in the past and the chef has been notified. Thanks for your interest.'
        end

        if params.has_key?(:page_return)
          if params[:page_return] == 'Favorite Chefs'
            redirect_to following_path
          else
            redirect_to user_path(User.find(mi.user_id).permalink)
          end
        else
          redirect_to menuitem_path(params[:menuitem])
        end  
      end
    end

    def edit
      # @req = Recipereq.find_by_permalink(params[:id])

      @menuitem = @req.menuitem
      @chef = User.find(@req.chef_id)
      @chef_addresses = @chef.addressusers.where('allow_booking_flag = 1 and line1 is not null')
    end

    def update
      if @req.update_attributes(params[:recipereq]) 
        UserMailer.to_chef_recipe_evt_req(@req).deliver
        flash[:success] = 'Your request has been submitted. We will email you once the chef has reviewed the request.'
        redirect_to user_path(User.find(@req.chef_id).permalink)
      else
        flash[:error] = 'Sorry, we encountered an error while submitting your request. Please try again.'
        redirect_to edit_recipereq_path(@req.permalink)
      end
    end

    def destroy
      mi = Menuitem.find_by_permalink(params[:id])
      recipereq = current_user.recipereqs.find_by_menuitem_id(mi.id)
      mi_chef = User.find(mi.user_id)

      if recipereq.destroy
        flash[:success] = 'Your request has been removed'
      else
        flash[:error] = 'Sorry, we encountered an error. Please try again. If this error persists, please contact us with the details.'
      end

       if params.has_key?(:page_return)
        if params[:page_return] == "Favorite Chefs"
          redirect_to following_path
        else
          redirect_to user_path(mi_chef.permalink)
        end
      else
        redirect_to menuitem_path(params[:id])
      end
    end


  def show
    @req = Recipereq.find_by_permalink(params[:id])

    if @req.chef_id != current_user.id
      flash[:error] = 'Only the owner of this recipe can view this request. Please login as the correct user and try again.'  
      redirect_to user_path(User.find(@req.chef_id).permalink)
    else
      @menuitem = Menuitem.find(@req.menuitem_id)
      @host = User.find(@req.user_id)
    end    
  end

  def update_status
    @req = Recipereq.find_by_permalink(params[:permalink])

    if @req.chef_id != current_user.id
      flash[:error] = 'Only the owner of this recipe can update the status for this request. Please login as the correct user and try again.'  
      redirect_to user_path(User.find(@req.chef_id).permalink)
    else
      if @req.update_attribute(:req_status, params[:req_status]) 
        if @req.req_status == 1
          redirect_to new_evt_from_req_path(@req.permalink)
        else
          flash[:warning] = 'The request was successfully declined.'
          redirect_to recipereqs_path
        end
      else
        flash[:error] = 'Sorry, we encountered an error while updating the request. Please try again.'
        redirect_to recipereq_path(@req.permalink)
      end
    end    
  end

  private

    def correct_user
      @req = Recipereq.find_by_permalink(params[:id])
      if @req.user_id != current_user.id
        flash[:error] = 'First, request the recipe as a Host before updating request information.' 
        redirect_to user_path(User.find(@req.chef_id).permalink)
      end
    end
end