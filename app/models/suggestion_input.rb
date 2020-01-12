# == Schema Information
#
# Table name: suggestion_inputs
#
#  id            :integer          not null, primary key
#  suggestion_id :integer
#  user_id       :integer
#  want          :integer
#  like_vote     :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class SuggestionInput < ActiveRecord::Base
  attr_accessible :like_vote, :suggestion_id, :user_id, :want

  belongs_to :user
  belongs_to :suggestion
end
