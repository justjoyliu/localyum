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

class HostPenalty < ActiveRecord::Base
  attr_accessible :amt_refunded_cents, :hostevent_id, :number_guests, :penalty_amount_cents, :user_id

  belongs_to :user
  belongs_to :hostevent
end
