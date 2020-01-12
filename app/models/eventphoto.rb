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

class Eventphoto < ActiveRecord::Base
  attr_accessible :onlyattendeeview, :photodescription, :eventpic
  
  # has_and_belongs_to_many :hostevents, :uniq => true
  # belongs_to :user

  belongs_to :hostevent

  has_attached_file :eventpic, 
      #:default_url => 'avatardefault.png',
      # :styles => { :main => "800x440#", :medium => "300x300>", :index_search => "300x200#", :thumb => "80x80#" },
      :styles => { :main => "800x440^", :medium => "300x300>", :index_search => "300x200^", :thumb => "80x80^" },
      :convert_options => { :main => " -gravity center -crop '800x440+0+0'",
                            :index_search => " -gravity center -crop '300x200+0+0'",
                            :thumb => " -gravity center -crop '80x80+0+0'"
                          },
      :url => "/eventphotos/:style/:id/:basename.:extension", 
      :path => ":rails_root/public/eventphotos/:style/:id/:basename.:extension"
      # :url => "/assets/eventphotos/:style/:id/:basename.:extension", 
      # :path => ":rails_root/public/assets/eventphotos/:style/:id/:basename.:extension"

   validates :eventpic_file_size, :numericality =>  {less_than: 5000}
  #validates photo
    validates_attachment_size :eventpic, :less_than=>10.megabyte
    validates_attachment_content_type :eventpic, :content_type=>['image/jpeg', 'image/jpg' 'image/png', 'image/gif', 'image/pjpeg'] 

  # before_create :default_description

  # def default_description
  #   self.photodescription ||= File.basename(self.eventpic_file_name).titleize if eventpic
  # end

end
