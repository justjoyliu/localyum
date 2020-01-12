# == Schema Information
#
# Table name: metroareas
#
#  id                 :integer          not null, primary key
#  metro_name         :string(255)
#  metro_name_nospace :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class Metroarea < ActiveRecord::Base
  attr_accessible :metro_name, :metro_name_nospace

  has_many :addressusers
  has_many :hostevents, :through => :addressusers
end
