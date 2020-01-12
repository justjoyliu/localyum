# == Schema Information
#
# Table name: eventactivities
#
#  id         :integer          not null, primary key
#  activity   :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Eventactivity < ActiveRecord::Base
  attr_accessible :activity
  has_and_belongs_to_many :hostevents, :uniq => true
end
