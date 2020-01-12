# == Schema Information
#
# Table name: eventphotos
#
#  id                    :integer          not null, primary key
#  hostevent_id          :integer
#  photodescription      :string(255)
#  onlyattendeeview      :boolean          default(FALSE)
#  eventpic_file_name    :string(255)
#  eventpic_content_type :string(255)
#  eventpic_file_size    :integer
#  eventpic_updated_at   :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

require 'spec_helper'

describe Eventphoto do
  pending "add some examples to (or delete) #{__FILE__}"
end
