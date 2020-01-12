# == Schema Information
#
# Table name: charitypolicies
#
#  id                :integer          not null, primary key
#  percentcontribute :integer
#  charityname       :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Charitypolicy < ActiveRecord::Base
  attr_accessible :charityname, :percentcontribute

  has_many :hostevents
end
