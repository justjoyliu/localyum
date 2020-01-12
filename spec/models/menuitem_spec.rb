# == Schema Information
#
# Table name: menuitems
#
#  id                   :integer          not null, primary key
#  name                 :string(255)
#  course               :string(255)
#  description          :string(255)
#  recipe               :text
#  recipeview           :string(255)
#  notes                :text
#  spicyscale           :integer
#  sweetscale           :integer
#  flavorinstensity     :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  user_id              :integer
#  ingredient           :text
#  menupic_file_name    :string(255)
#  menupic_content_type :string(255)
#  menupic_file_size    :integer
#  menupic_updated_at   :datetime
#  permalink            :string(255)
#

require 'spec_helper'

describe Menuitem do
  pending "add some examples to (or delete) #{__FILE__}"
end
