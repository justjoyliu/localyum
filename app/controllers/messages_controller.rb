class MessagesController < ApplicationController
  before_filter :signed_in_user, only: [:create, :destroy]
  before_filter :active_user, only: [:create, :destroy]

  def create
    msg_hash = {:sender_id => current_user.id, 
      :messagechain_id => Messagechain.find_by_permalink(params[:message][:messagechain_id]).id, 
      :message_content => params[:message][:message_content], 
      :receiver_id => User.find_by_permalink(params[:message][:receiver_id]).id
    }

    if params[:message].has_key?(:replied_to_msg_id)
      @message = Message.create(msg_hash.merge(:replied_to_msg_id => params[:message][:replied_to_msg_id]))
      @chain = @message.messagechain

      @reply_to_msg = Message.find(params[:message][:replied_to_msg_id])

      if @reply_to_msg.receiver_id == current_user.id
        @reply_to_msg.update_attribute(:receiver_replied, true)
        @reply_to_msg.update_attribute(:receiver_read, true)
      end 
    else
      @message = Message.create(msg_hash)
      @chain = @message.messagechain
    end

    unless @chain.nil?
      @message.update_attribute(:order_id, @chain.messages.maximum("order_id") + 1)
    end
    
    if @message.save
      flash[:success] = "Your message has been sent."
    end

    redirect_to(messagechains_path || root_url)
  end

  # used in _message_inbox
  def destroy
    @message = Message.find(params[:id])

    if @message.sender_id == current_user.id
       @message.update_attribute(:sender_hidden, true)
     elsif @message.receiver_id == current_user.id
       @message.update_attribute(:receiver_hidden, true)
     else
       flash[:error] = 'You can only delete messages you have sent or received.'
     end 

    redirect_to messagechains_path
  end

end