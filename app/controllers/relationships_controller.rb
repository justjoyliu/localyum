class RelationshipsController < ApplicationController
  before_filter :signed_in_user
  before_filter :active_user

  # def index
    
  # end
  
  def create
    @chef = User.find_by_permalink(params[:relationship][:followed_id])
    current_user.follow!(@chef)
    respond_to do |format|
      format.html { redirect_to user_path(@chef.permalink) }
      format.js
    end
  end

  def destroy
    @chef = Relationship.find(params[:id]).followed
    current_user.unfollow!(@chef)
    respond_to do |format|
      format.html { redirect_to user_path(@chef.permalink) }
      format.js
    end
  end
end