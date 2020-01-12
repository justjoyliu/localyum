class MenuitemsController < ApplicationController
  #before_filter :admin_user, only: [:create, :destroy]
  before_filter :signed_in_user, only: [:index, :show, :my_events_recipes, :create, :destroy, :edit, :update, :new]
  before_filter :active_user, only: [:create, :destroy, :edit, :update, :update_from_evt, :new]
  before_filter :correct_user,   only: [:edit, :update, :update_from_evt, :destroy]

  def index
    #@eventactivities = Eventactivity.all
    @myrecipes = current_user.menuitems.paginate(:per_page => 12, :page => params[:page])
  end

  def show
    @item = Menuitem.find_by_permalink(params[:permalink])  
    @featured = @item.hostevents.where("eventstatus = ?", "Open")
    @requested_count = @item.recipereqs.count
    
    @current_user_signup = 0

    @featured.each do |f|
      # @current_user_signup += f.signups.where("confirmation_status = ? and user_id = ?", "Confirmed", current_user.id).count
      @current_user_signup += f.signups.where("confirmation_status = ? and user_id = ?", "Attending", current_user.id).count
    end 
  end

  def my_events_recipes
    # @evts = current_user.hostevents.where("confirmation_status = ?", "Confirmed")
    @evts = current_user.hostevents.where("confirmation_status = ?", "Attending")
    @myrecipes = Array.new

    @evts.each do |e|
      e.menuitems.each do |i|
        if @myrecipes.include?(i)
          
        else
          @myrecipes << i
        end
      end
    end 

    @myrecipes = @myrecipes.paginate(:per_page => 12, :page => params[:page])
  end

  def new
    @menuitem = Menuitem.new
  end

  def create
    if params.has_key?(:event_id)
      @hostevent = Hostevent.find_by_permalink(params[:event_id])
      menuitem_hash = params[:menuitem].merge(:hostevent_ids => @hostevent.id)

      @menuitem = current_user.menuitems.build(menuitem_hash)
      if @menuitem.save
        flash[:success] = "Your dish has been added to the menu."
      else
        if @menuitem.errors[:menupic_file_size]
          @menuitem_withoutpic = current_user.menuitems.build(:name => params[:menuitem][:name], 
            :course => params[:menuitem][:course],
            :recipeview => params[:menuitem][:recipeview], 
            :description => params[:menuitem][:description],
            :ingredient => params[:menuitem][:ingredient],
            :recipe => params[:menuitem][:recipe],
            :notes => params[:menuitem][:notes], 
            :hostevent_ids => @hostevent.id
            )
          @menuitem_withoutpic.save
          flash[:error] = 'Your recipe picture must be less than 5MB.'
        elsif @menuitem.errors[:menupic_content_type]
          @menuitem_withoutpic = current_user.menuitems.build(:name => params[:menuitem][:name], 
            :course => params[:menuitem][:course],
            :recipeview => params[:menuitem][:recipeview], 
            :description => params[:menuitem][:description],
            :ingredient => params[:menuitem][:ingredient],
            :recipe => params[:menuitem][:recipe],
            :notes => params[:menuitem][:notes], 
            :hostevent_ids => @hostevent.id
            )
          @menuitem_withoutpic.save
          flash[:error] = "Your recipe picture must be in jpeg, png, or gif format."
        else
          flash[:error] = 'Sorry, we encountered an error while creating your recipe. Please try again.'
        end
      end
      redirect_to edit_hostevent_path(@hostevent.permalink)
    else
      @menuitem = current_user.menuitems.build(params[:menuitem])
      if @menuitem.save
        flash[:success] = "Your dish has been added to your recipe box."
        redirect_to my_recipebox_path
      else
        if @menuitem.errors[:menupic_file_size]
          @menuitem_withoutpic = current_user.menuitems.build(:name => params[:menuitem][:name], 
            :course => params[:menuitem][:course],
            :recipeview => params[:menuitem][:recipeview], 
            :description => params[:menuitem][:description],
            :ingredient => params[:menuitem][:ingredient],
            :recipe => params[:menuitem][:recipe],
            :notes => params[:menuitem][:notes]
            )
          @menuitem_withoutpic.save
          flash[:error] = 'Your recipe picture must be less than 5MB.'
          redirect_to edit_menuitem_path(@menuitem_withoutpic.permalink)
        elsif @menuitem.errors[:menupic_content_type]
          @menuitem_withoutpic = current_user.menuitems.build(:name => params[:menuitem][:name], 
            :course => params[:menuitem][:course],
            :recipeview => params[:menuitem][:recipeview], 
            :description => params[:menuitem][:description],
            :ingredient => params[:menuitem][:ingredient],
            :recipe => params[:menuitem][:recipe],
            :notes => params[:menuitem][:notes]
            )
          @menuitem_withoutpic.save
          flash[:error] = "Your recipe picture must be in jpeg, png, or gif format."
          edit_menuitem_path(@menuitem_withoutpic.permalink)
        else
          flash[:error] = 'Sorry, we encountered an error while creating your recipe. Please try again.'
          redirect_to my_recipebox_path
        end
      end
      # redirect_to my_recipebox_path
    end
  end

  def destroy
    if @item.hostevents.count > 0
      flash[:error] = 'You cannot delete a recipe that was featured in an event.'
    else
      @item.destroy
      flash[:success] = 'The recipe was deleted in our system.'
    end
    
    redirect_to my_recipebox_path
  end

  def edit
   # @item = Menuitem.find(params[:id])  
   # session.delete(:return_to) 
   @user_agent = UserAgent.parse(request.env["HTTP_USER_AGENT"])
  end

  def update
    # @menuitem = Menuitem.find(params[:id])
    if @item.update_attributes(params[:menuitem]) 
      flash[:success] = 'Your menu has been updated'
      redirect_to menuitem_path(@item.permalink)
    elsif @item.errors[:menupic_file_size]
          flash[:error] = 'Your recipe picture must be less than 5MB.'
          redirect_to edit_menuitem_path(@item.permalink)
    elsif @item.errors[:menupic_content_type]
          flash[:error] = "Your recipe picture must be in jpeg, png, or gif format."
          edit_menuitem_path(@item.permalink)
    else
          flash[:error] = 'Sorry, we encountered an error while editing your recipe. Please try again.'
          edit_menuitem_path(@item.permalink)
    end

    # redirect_to menuitem_path(@item.permalink)
    # session.delete(:return_to) 
  end

  def update_from_evt
    # @menuitem = Menuitem.find_by_permalink(params[:id])
    if @item.update_attributes(params[:menuitem]) 
      flash[:success] = 'Your menu has been updated'
    elsif @item.errors[:menupic_file_size]
          flash[:error] = 'Your recipe picture must be less than 5MB.'
    elsif @item.errors[:menupic_content_type]
          flash[:error] = "Your recipe picture must be in jpeg, png, or gif format."
    else
          flash[:error] = 'Sorry, we encountered an error while editing your recipe. Please try again.'
    end
    redirect_to edit_hostevent_path(params[:hostevent_id_from])
  end

private

    def correct_user
      @item = current_user.menuitems.find_by_permalink(params[:permalink])
      if @item.nil?
        flash[:error] = 'Sorry, but you must be the menu item creator in order to access page'
        redirect_to menuitem_path(params[:permalink])    
      end
    end
end