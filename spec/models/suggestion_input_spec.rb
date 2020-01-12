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

require 'spec_helper'

describe SuggestionInput do
  pending "add some examples to (or delete) #{__FILE__}"
end
