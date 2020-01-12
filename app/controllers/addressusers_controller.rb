class AddressusersController < ApplicationController
  
  #include AddressusersHelper
  before_filter :signed_in_user
  before_filter :correct_user, only: [:update, :delete_address]

  def index
    #@hostevents = Hostevent.all
    @addresses = current_user.addressusers.where("line1 is not null")
    @new_address = Addressuser.new
  end

  def new
    @addressuser = Addressuser.new
  end

  def create

    # @addressuser = current_user.addressusers.build(params[:addressuser])

    addressuser_hash = params[:addressuser].merge(:user_id => current_user.id)

    @addressuser = current_user.addressusers.build(addressuser_hash)

    if @addressuser.save 
      @lat = @addressuser.latitude - 0.005 + (Random.rand(10000).to_f/1000000)
      @lng = @addressuser.longitude - 0.005 + (Random.rand(10000).to_f/1000000)

      if @addressuser.update_attributes(:lat_rand => @lat, :lng_rand => @lng)
        #length of 1° of latitude = 1° * 69.172 miles
        flash[:success] = "Address added!"
      end
      # redirect_to(session[:return_to] || root_url)
      # session.delete(:return_to) 
    end 

    if params.has_key?(:hostevent_id)
      @hostevent = Hostevent.find_by_permalink(params[:hostevent_id])
      if @hostevent.update_attribute(:addressuser_id, @addressuser.id)
        flash[:success] = 'Address added'
      end 
      redirect_to step2_path(params[:hostevent_id])
    else
      redirect_to my_address_book_path
    end
  end

  def delete_address
      if current_user.upcomingevents_as_host.where("addressuser_id = ?", params[:id]).count == 0
        @address.update_attribute(:line1, nil) 
        @address.update_attribute(:latitude, nil) 
        @address.update_attribute(:longitude, nil) 

        flash[:success] = "The address was successfully deleted."
        redirect_to my_address_book_path
      else
        flash[:error] = "You can only delete addresses where there are no upcoming events. Please make sure you have re-located all events at the location before deleting the address."
        redirect_to my_address_book_path
      end
  end

  def update
    if @address.update_attributes(params[:addressuser]) and !@address.latitude.nil? and !@address.longitude.nil?
      @lat = @address.latitude - 0.005 + (Random.rand(10000).to_f/1000000)
      @lng = @address.longitude - 0.005 + (Random.rand(10000).to_f/1000000)

      if @address.update_attributes(:lat_rand => @lat, :lng_rand => @lng)
        #length of 1° of latitude = 1° * 69.172 miles
        flash[:success] = 'Address was updated successfully.'
      end
    else
      flash[:error] = 'Please verify the address you entered is correct. We could not find a proper coordinate for it in our system.'
    end

    redirect_to my_address_book_path
  end

  private

    def correct_user
      @address = current_user.addressusers.find(params[:id])
      if @address.nil?
        flash[:error] = 'You must be the address creator to edit or delete the address.'
        redirect_to my_address_book_path
      end
    end

end