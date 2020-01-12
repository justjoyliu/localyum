# == Schema Information
#
# Table name: signups
#
#  id                    :integer          not null, primary key
#  hostevent_id          :integer
#  user_id               :integer
#  confirmation_host     :boolean          default(FALSE)
#  confirmation_guest    :boolean          default(FALSE)
#  confirmation_status   :string(255)
#  payment_status        :string(255)      default("Pending")
#  payment_amt           :decimal(12, 2)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  taste_rating          :integer
#  experience_rating     :integer
#  charge_id             :string(255)
#  card_id               :string(255)
#  pay_portal_fee_cents  :integer
#  card_last_4           :integer
#  card_mth              :integer
#  card_yr               :integer
#  pay_failure_msg       :string(255)
#  refund_amt_cent       :integer
#  card_status           :string(255)      default("ok")
#  dispute_flag          :boolean          default(FALSE)
#  host_rating_for_guest :integer
#  permalink             :string(255)
#  guest_count           :integer          default(1)
#  own_group_flag        :boolean          default(FALSE)
#

require 'spec_helper'

describe Signup do
  pending "add some examples to (or delete) #{__FILE__}"
end
