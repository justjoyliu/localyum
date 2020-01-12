# == Schema Information
#
# Table name: cancellationpolicies
#
#  id                       :integer          not null, primary key
#  hrs_before_1             :integer
#  refund_percent_1         :integer
#  hrs_before_2             :integer
#  refund_percent_2         :integer
#  cancellation_description :string(255)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

require 'spec_helper'

describe Cancellationpolicy do
  pending "add some examples to (or delete) #{__FILE__}"
end
