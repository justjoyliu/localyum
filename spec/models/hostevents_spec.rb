# == Schema Information
#
# Table name: hostevents
#
#  id                    :integer          not null, primary key
#  startdate             :date
#  mealstarttime         :time
#  price                 :integer
#  guestallowforprep     :boolean
#  timestartprep         :time
#  minguests             :integer
#  maxguests             :integer
#  discussiontopics      :text
#  bestwaytocontact      :string(255)
#  extracomments         :text
#  requestsforguests     :text
#  mustbookdaysinadvance :integer
#  user_id               :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

require 'spec_helper'

describe Hostevents do
  pending "add some examples to (or delete) #{__FILE__}"
end
