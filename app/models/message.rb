# == Schema Information
#
# Table name: messages
#
#  id                :integer          not null, primary key
#  sender_id         :integer
#  receiver_id       :integer
#  messagechain_id   :integer
#  first_flag        :boolean          default(FALSE)
#  message_content   :text
#  receiver_read     :boolean          default(FALSE)
#  receiver_replied  :boolean          default(FALSE)
#  public_flag       :boolean          default(FALSE)
#  order_id          :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  sender_hidden     :boolean          default(FALSE)
#  receiver_hidden   :boolean          default(FALSE)
#  signup_id         :integer
#  replied_to_msg_id :integer
#

class Message < ActiveRecord::Base
  attr_accessible :sender_id, :receiver_id, :messagechain_id, 
  	:receiver_read, :receiver_replied,
  	:first_flag, :message_content, :public_flag, :order_id, 
    :replied_to_msg_id, :signup_id, :sender_hidden, :receiver_hidden

  belongs_to :sender, :class_name => "User", :foreign_key => :user_id
  belongs_to :receiver, :class_name => "User", :foreign_key => :user_id
  belongs_to :messagechain

  validates :sender_id, presence: true
  validates :messagechain_id, presence: true
  validates :message_content, presence: true

  def msg_collapse(item)
    # "\"#collapsemenuitem" + item.id.to_s + "\""
    "#collapsemsg" + item.id.to_s
  end

  def msg_collapse_inner(item)
    # "\"collapsemenuitem" + item.id.to_s + "\""
    "collapsemsg" + item.id.to_s
  end
end
