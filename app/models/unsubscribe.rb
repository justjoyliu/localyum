# == Schema Information
#
# Table name: unsubscribes
#
#  id         :integer          not null, primary key
#  email      :string(255)
#  status     :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#

class Unsubscribe < ActiveRecord::Base
  attr_accessible :email, :user_id

  belongs_to :user
end
