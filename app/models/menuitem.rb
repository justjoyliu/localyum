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

class Menuitem < ActiveRecord::Base
  attr_accessible :course, :description, :flavorinstensity, :name, :notes, :recipe, :recipeview, :spicyscale, :sweetscale, 
  	:hostevent_ids, :ingredient, :menupic

  before_create :make_permalink

  has_and_belongs_to_many :hostevents, :uniq => true
  belongs_to :user

  has_many :recipereqs
  has_many :messagechains
  has_many :messages, :through => :messagechains

  has_attached_file :menupic, 
      :default_url => 'menupicdefault.png',
      # :styles => { :wide => "800x300#", :medium => "250x250#", :thumb => "100x100#", :main => "800x440#", :index_search => "300x200#" },
      :styles => { :wide => "800x300^", :medium => "250x250^", :thumb => "100x100^", :main => "800x440^", :index_search => "300x200^" },
      :convert_options => { :wide => " -gravity center -crop '800x300+0+0'",
                            :medium => " -gravity center -crop '250x250+0+0'",
                            :thumb => " -gravity center -crop '100x100+0+0'",
                            :main => " -gravity center -crop '800x440+0+0'",
                            :index_search => " -gravity center -crop '300x200+0+0'"
                          },
      :url => "/menuitems/:style/:id/:basename.:extension", 
      :path => ":rails_root/public/menuitems/:style/:id/:basename.:extension"

  validates :name, presence: true #, uniqueness: { case_sensitive: false }
  # validates :description, presence: true
  validates :course, presence: true
  validates :user_id, presence: true

  validates_attachment_size :menupic, :less_than=>5.megabyte
  validates_attachment_content_type :menupic, :content_type=>['image/jpeg', 'image/jpg' 'image/png', 'image/gif', 'image/pjpeg'] 

  def menuitem_collapse(item)
    # "\"#collapsemenuitem" + item.id.to_s + "\""
    "#collapsemenuitem" + item.id.to_s
  end

  def menuitem_collapse_inner(item)
    # "\"collapsemenuitem" + item.id.to_s + "\""
    "collapsemenuitem" + item.id.to_s
  end

  def course_select
  	[ 
  		'Appetizer',
  		'Soup',
  		'Main',
  		'Side', 
  		'Salad',
  		'Cheese',
  		'Dessert', 
      'Wine', 
      'Beverage', 
      'Activity'
	  ]
  end

  def recipe_view_select
  	[ 
  		'Everyone',
  		'Only Friends Attending Event',
  		'Only Me'
	  ]
  end

  def menuitem_optional_field?
    if !self.ingredient.blank? || !self.notes.blank? || (self.recipeview != 'Only Me' && !self.recipe.blank?)
      return true
    end
    
    return false
  end

  private
    def make_permalink
      self.permalink = loop do
        # random_token = SecureRandom.urlsafe_base64(nil, false)
        random_token = SecureRandom.hex(8)
        break random_token unless Menuitem.where(permalink: random_token).exists?
      end
    end
end
