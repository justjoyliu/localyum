# == Schema Information
#
# Table name: messagechains
#
#  id           :integer          not null, primary key
#  hostevent_id :integer
#  title        :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  menuitem_id  :integer
#  permalink    :string(255)
#

require 'spec_helper'

describe Messagechain do
  pending "add some examples to (or delete) #{__FILE__}"
end
