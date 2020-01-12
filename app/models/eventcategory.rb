# == Schema Information
#
# Table name: eventcategories
#
#  id           :integer          not null, primary key
#  categorytype :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Eventcategory < ActiveRecord::Base
  attr_accessible :categorytype

  has_many :hostevents
end
