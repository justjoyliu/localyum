# == Schema Information
#
# Table name: addressusers
#
#  id                 :integer          not null, primary key
#  line1              :string(255)
#  city               :string(255)
#  state              :string(255)
#  zip5               :string(255)
#  metroarea          :string(255)
#  user_id            :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  latitude           :float
#  longitude          :float
#  nickname           :string(255)
#  neighborhood       :string(255)
#  gmaps              :boolean
#  lat_rand           :float
#  lng_rand           :float
#  private_flag       :boolean          default(FALSE)
#  allow_booking_flag :boolean          default(TRUE)
#

require 'spec_helper'

describe Addressuser do
  pending "add some examples to (or delete) #{__FILE__}"
end
