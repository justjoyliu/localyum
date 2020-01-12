class MessagechainsController < ApplicationController
  #before_filter :admin_user, only: [:create, :destroy]
  before_filter :signed_in_user, only: [:create, :index, :show]
  before_filter :active_user, only: [:create, :index, :show]

  def create
    # if params[:messagechain].has_key?(:menuitem_id)
    #   if params[:messagechain][:messages_attributes]["0"][:receiver_id] == params[:messagechain][:messages_attributes]["0"][:sender_id]
    #     flash[:error] = "You cannot request a tasting of your own recipe."
    #     redirect_to user_path(params[:messagechain][:messages_attributes]["0"][:receiver_id])
    #   else
    #     @chain = Messagechain.create(:menuitem_id => params[:messagechain][:menuitem_id], :title => params[:messagechain][:title])
    #     @msg = @chain.messages.create(params[:messagechain][:messages_attributes]["0"])
    #     flash[:success] = "Tasting request sent"
    #     redirect_to user_path(params[:messagechain][:messages_attributes]["0"][:receiver_id])
    #   end
    if params[:messagechain].has_key?(:hostevent) && params[:messagechain].has_key?(:message)
      # in hostevent_ratings, messaging specific guest
      # in _past_events, add rating comment
      # in hostevent show, add rating comment
      @hostevent = Hostevent.find_by_permalink(params[:messagechain][:hostevent])
      @chain = Messagechain.create(:hostevent_id => @hostevent.id)        

      if params[:messagechain].has_key?(:title)
        @chain.update_attribute(:title, params[:messagechain][:title])
      end

      if !params[:messagechain][:message].has_key?(:message_content) || params[:messagechain][:message][:message_content].to_s.empty?
        flash[:error] = "Your message/comment must have text content in order for us to post it."
        redirect_to hostevent_path(@hostevent.permalink)
      elsif params[:messagechain].has_key?(:receiver)
        @chain.messages.create(params[:messagechain][:message].merge(:sender_id => current_user.id, :receiver_id => User.find_by_permalink(params[:messagechain][:receiver]).id))
        flash[:success] = 'Thanks! Your message has been sent.'
        redirect_to hostevent_path(@hostevent.permalink)
      elsif params[:messagechain].has_key?(:signup)
        @chain.messages.create(params[:messagechain][:message].merge(:sender_id => current_user.id, :signup_id => Signup.find_by_permalink(params[:messagechain][:signup]).id, :receiver_id => @hostevent.user_id))
        flash[:success] = 'Thanks! Your rating has been received.'
        redirect_to hostevent_path(@hostevent.permalink)
      elsif @hostevent.user_id == current_user.id
        @hostevent.guests_attending.each do |g|
          @msg = @chain.messages.create(params[:messagechain][:message].merge(:sender_id => current_user.id, :receiver_id => g.user_id))
        end
        flash[:success] = 'Thanks! Your message has been sent.'
        redirect_to hostevent_path(@hostevent.permalink)
      else
        @msg = @chain.messages.create(params[:messagechain][:message].merge(:sender_id => current_user.id, :receiver_id => @hostevent.user_id))
        flash[:success] = 'Thanks! Your message has been sent.'
        redirect_to hostevent_path(@hostevent.permalink)
      end
    elsif params[:messagechain].has_key?(:hostevent) && (!params[:messagechain][:messages_attributes]["0"].has_key?(:message_content) || params[:messagechain][:messages_attributes]["0"][:message_content].to_s.empty?)
      # in hostevent_ratings, adding comment
      flash[:error] = "Your message/comment must have text content in order for us to post it."
      redirect_to hostevent_path(params[:messagechain][:hostevent])
    elsif params[:messagechain].has_key?(:hostevent) && !params[:messagechain].has_key?(:receiver)
      # in hostevent_ratings, adding comment
      # in hostevent show, adding comment
      @hostevent = Hostevent.find_by_permalink(params[:messagechain][:hostevent])
      @guests = @hostevent.guests_attending

      @chain = Messagechain.create(:hostevent_id => @hostevent.id)

      if params[:messagechain].has_key?(:title)
        @chain.update_attribute(:title, params[:messagechain][:title])
      end
      
      if @guests.count > 0 && @hostevent.user_id == current_user.id
        @guests.each do |g|
          @msg = @chain.messages.create(params[:messagechain][:messages_attributes]["0"].merge(:sender_id => current_user.id, :receiver_id => g.user_id))
        end
      elsif @hostevent.user_id != current_user.id
        @msg = @chain.messages.create(params[:messagechain][:messages_attributes]["0"].merge(:sender_id => current_user.id, :receiver_id => @hostevent.user_id))
      else
        @chain.messages.create(params[:messagechain][:messages_attributes]["0"].merge(:sender_id => current_user.id))
      end
      
      if @chain.messages.count > 0
        flash[:success] = "Thanks. Your comment has ben published!"
      end

      redirect_to hostevent_path(params[:messagechain][:hostevent])  
    elsif params[:messagechain].has_key?(:receiver) && params[:messagechain][:receiver] == current_user.permalink
          flash[:error] = 'You cannot send a message to yourself'
          if params[:messagechain].has_key?(:hostevent)
            redirect_to hostevent_path(params[:messagechain][:hostevent])  
          else
            redirect_to messagechains_path
          end
    else
      # in hostevent show, messaging host
      @hostevent = Hostevent.find_by_permalink(params[:messagechain][:hostevent])
      @chain = Messagechain.create(:hostevent_id => @hostevent.id, :title => params[:messagechain][:title])
      @msg = @chain.messages.create(params[:messagechain][:messages_attributes]["0"].merge(:sender_id => current_user.id, :receiver_id => User.find_by_permalink(params[:messagechain][:receiver]).id))
      if @msg.save
        flash[:success] = "Thanks! Your message has been sent."
      end

      if params[:messagechain].has_key?(:hostevent)
        redirect_to hostevent_path(params[:messagechain][:hostevent])  
      else
        redirect_to messagechains_path
      end
    end
  end

  def index
    @messages = Message.where("(sender_id = ? AND sender_hidden = 0 AND signup_id is null) OR (receiver_id = ? AND receiver_hidden = 0)", current_user.id, current_user.id).order("created_at desc")
    @message_sent = @messages.find_all_by_sender_id(current_user.id)
    @message_received = @messages.find_all_by_receiver_id(current_user.id)

    @measage_read = 0
    @message_replied = 0

    @message_received.each do |r|
      if r.receiver_read?
        @measage_read += 1
      end

      if r.receiver_replied?
        @message_replied += 1
      end
    end
    # @message_grps = @messages.max(:group=>:messagechain_id)

    @msg_chains = Array.new
    @chain_ids = Array.new

    @messages.each do |m|
      if @chain_ids.exclude?(m.messagechain.id)    
        @msg_chains << [m.messagechain, m] 
        @chain_ids << m.messagechain.id
      end
    end 

    @msg_chains = @msg_chains.paginate(:per_page => 6, :page => params[:page])    
  end

  def show
    @chain = Messagechain.find_by_permalink(params[:permalink])
    @messages = @chain.messages.where("(sender_id = ? AND sender_hidden = 0) OR (receiver_id = ? AND receiver_hidden = 0)", current_user.id, current_user.id).order("created_at desc")
    
    if !@chain.hostevent.nil?
      @evt = @chain.hostevent
    end

    @messages.each do |m|
      if current_user.id == m.receiver_id
        m.update_attribute(:receiver_read, true)
      end
    end

    @reply = @chain.messages.build()
  end

end