# == Schema Information
#
# Table name: suggestions
#
#  id                  :integer          not null, primary key
#  feature_description :string(255)
#  status              :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class Suggestion < ActiveRecord::Base
  attr_accessible :feature_description, :status

  has_many :suggestion_inputs
end
