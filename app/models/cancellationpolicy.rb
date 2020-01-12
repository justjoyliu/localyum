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

class Cancellationpolicy < ActiveRecord::Base
  attr_accessible :hrs_before_1, :hrs_before_2, :refund_percent_1, :refund_percent_2, :cancellation_description
  
  has_many :hostevents
  
end