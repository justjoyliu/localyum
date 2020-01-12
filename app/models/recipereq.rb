# == Schema Information
#
# Table name: recipereqs
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  menuitem_id        :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  chef_id            :integer
#  as_host_flag       :boolean          default(FALSE)
#  req_date           :string(255)
#  req_detail         :text
#  est_guests         :string(255)
#  price_range        :string(255)
#  req_addressuser_id :integer
#  req_status         :integer          default(0)
#  hostevent_id       :integer
#  permalink          :string(255)
#

class Recipereq < ActiveRecord::Base
  attr_accessible :menuitem_id, :user_id, :chef_id, 
  	:as_host_flag, :req_date, :req_detail, :est_guests, :price_range, :req_addressuser_id,
  	:req_status, :hostevent_id

  belongs_to :user
  belongs_to :menuitem

  has_many :hostevents

  before_create :make_permalink
  
  private

    def make_permalink
      self.permalink = loop do
        # random_token = SecureRandom.urlsafe_base64(nil, false)
        random_token = SecureRandom.hex(8)
        break random_token unless Hostevent.where(permalink: random_token).exists?
      end
    end 
end
