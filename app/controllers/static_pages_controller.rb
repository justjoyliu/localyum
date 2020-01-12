class StaticPagesController < ApplicationController
  def home
    # signed_in then ...
      # if current_user.nil?
        # @user = User.new
        # @contact_form = UserMailer.new
        # session.delete(:return_to)
      # else
      #   # for suggestions
      #     @voting = Suggestion.where("status = 'voting'")
      #     @liking = Suggestion.find_by_status("liking")

      #     unless @liking.nil?
      #       @user_l = @liking.suggestion_inputs.where("user_id = ? and like_vote is not null", current_user.id).first
      #     end

      #     unless @voting.empty?
      #       @voting.each do |v|
      #         if @user_v.nil?
      #           @user_v = v.suggestion_inputs.where("user_id = ? and want is not null", current_user.id).first
      #         end
      #       end
      #     end
      # end

    # find next 3 events
    @upcomingevts = Hostevent.where("eventstatus = ? AND startdate >= ?", "Open", Date.today).order(:mealstarttime)
    @upcomingevts_2 = @upcomingevts.limit(3)
    
    if @upcomingevts.count <= 3
      @past_2 = Hostevent.where("eventstatus = 'Open' AND id in (25, 19, 26)").order("mealstarttime DESC")
    end 
    # Time.now
    # Hostevent.where("mealstarttime > ? and eventstatus = ?", Date.today, "Open").order("mealstarttime ASC")
    # @donations = Hostevent.where("host_charity_cents is not null").joins('inner join addressusers on addressusers.id = hostevents.addressuser_id').select("addressusers.metroarea").group("metroarea").sum(:host_charity_cents)
    # @max_donate_community = @donations.values.map(&:to_i).max
  end

  def mobilehome
    if current_user.nil?
      @user = User.new
    else
      redirect_to root_path
    end
  end

  def help
  end

  def about
  end

  def how_it_works
  end
  
  def contact
  end

  def terms
  end

  def email_ly
    if UserMailer.contact_local_yum(params[:contact_form]).deliver
      flash[:success] = "Your message has been sent. We will respond back as soon as possible."
    else
      flash[:error] = "Sorry, we encountered an error. Please try again."
    end
    redirect_to root_path
  end

end
