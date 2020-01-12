# == Schema Information
#
# Table name: host_penalties
#
#  id                   :integer          not null, primary key
#  hostevent_id         :integer
#  user_id              :integer
#  number_guests        :integer
#  amt_refunded_cents   :integer
#  penalty_amount_cents :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

require 'spec_helper'

describe HostPenalty do
  pending "add some examples to (or delete) #{__FILE__}"
end
