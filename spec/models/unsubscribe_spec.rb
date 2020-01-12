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

require 'spec_helper'

describe Unsubscribe do
  pending "add some examples to (or delete) #{__FILE__}"
end
