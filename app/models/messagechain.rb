# == Schema Information
#
# Table name: messagechains
#
#  id           :integer          not null, primary key
#  hostevent_id :integer
#  title        :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  menuitem_id  :integer
#  permalink    :string(255)
#

class Messagechain < ActiveRecord::Base
  attr_accessible :hostevent_id, :menuitem_id, :title, :messages_attributes

  has_many :messages
  accepts_nested_attributes_for :messages

  belongs_to :hostevent
  belongs_to :menuitem

  before_create :make_permalink

  def make_permalink
    self.permalink = loop do
      random_token = SecureRandom.hex(8)
      break random_token unless Messagechain.where(permalink: random_token).exists?
    end
  end

  def count_message(user = current_user)
  	return Messagechain.where("(sender_id = ? AND sender_hidden = 0) OR (receiver_id = ? AND receiver_hidden = 0)", user.id, user.id).count
  end
end
