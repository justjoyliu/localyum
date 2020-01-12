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

require 'spec_helper'

describe Userbalance do
  pending "add some examples to (or delete) #{__FILE__}"
end
