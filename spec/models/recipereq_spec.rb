# == Schema Information
#
# Table name: recipereqs
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  menuitem_id        :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  chef_id            :integer
#  as_host_flag       :boolean          default(FALSE)
#  req_date           :string(255)
#  req_detail         :text
#  est_guests         :string(255)
#  price_range        :string(255)
#  req_addressuser_id :integer
#  req_status         :integer          default(0)
#  hostevent_id       :integer
#  permalink          :string(255)
#

require 'spec_helper'

describe Recipereq do
  pending "add some examples to (or delete) #{__FILE__}"
end
