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

require 'spec_helper'

describe Message do
  pending "add some examples to (or delete) #{__FILE__}"
end
