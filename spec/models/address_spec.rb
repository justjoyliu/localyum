# == Schema Information
#
# Table name: addresses
#
#  id         :integer          not null, primary key
#  line1      :string(255)
#  city       :string(255)
#  state      :string(255)
#  zip5       :string(255)
#  metroarea  :string(255)
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Address do
  pending "add some examples to (or delete) #{__FILE__}"
end
