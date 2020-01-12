# == Schema Information
#
# Table name: userbalances
#
#  id          :integer          not null, primary key
#  transfer_id :string(255)
#  amount      :integer
#  status      :string(255)
#  user_id     :integer
#  stripe_fee  :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Userbalance < ActiveRecord::Base
  attr_accessible :amount, :status, :stripe_fee, :transfer_id, :user_id
  
  has_many :hostevents
  belongs_to :user
end
