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

class Addressuser < ActiveRecord::Base
  attr_accessible :city, :line1, :metroarea, :state, :zip5, :user_id, :nickname, :neighborhood, :latitude, :longitude, :lat_rand, :lng_rand,
   :private_flag, :allow_booking_flag
    
  # geocoded_by :address
  # after_validation :geocode #, :if => :address_changed?

  acts_as_gmappable

  has_many :hostevents
  belongs_to :user

  validates :city,  presence: true
  validates :state,  presence: true
  validates :line1,  presence: true
  validates :metroarea,  presence: true

  # def address
	 #  [line1, city, state].compact.join(', ')
  # end

  def gmaps_circle
  	return '[{"lng": ' + lng_rand.to_s + ', "lat": ' + lat_rand.to_s + ', "radius": 700, "strokeColor": "#fc6049", "strokeWeight": 1, "fillColor": "#fd9381"}]' #r is 700 meters
  end

  def gmaps4rails_address
	#describe how to retrieve the address from your model, if you use directly a db column, you can dry your code, see wiki
  	"#{self.line1}, #{self.city}, #{self.state}" 
  end

  def address_city_state
  	return (self.line1.to_s + ", " + self.city.to_s + ", " + self.state.to_s)
  end

  def address_google_maps_link
    return "http://maps.google.com/?q=" + self.line1.to_s + ", " + self.city.to_s + ", " + self.state.to_s + ", " + self.zip5.to_s
  end

  def address_display_2lines
    return self.line1.to_s + "<br/>" + self.city.to_s + ", " + self.state.to_s + " " + self.zip5.to_s
  end

  def address_city_state_nickname
    if self.nickname.blank?
      return (self.line1.to_s + ", " + self.city.to_s + ", " + self.state.to_s)
    else
      return (self.nickname.to_s + ": " + self.line1.to_s + ", " + self.city.to_s + ", " + self.state.to_s)
    end
  end

  def address_collapse
    "#collapseaddress" + self.id.to_s
  end

  def address_collapse_inner
    "collapseaddress" + self.id.to_s
  end


  def target_metro
    [ 
      ['Metro Area: Other', 'Other'], 
      # ['Metro Area: Austin', 'Austin'],
      # ['Metro Area: Boston', 'Boston'],
      # ['Metro Area: Chicago', 'Chicago'],
      # ['Metro Area: Los Angeles', 'Los_Angeles'],
      # ['Metro Area: New York City', 'New_York_City'],
      ['Metro Area: Richmond', 'Richmond'],
      # ['Metro Area: San Francisco', 'San_Francisco'],
      ['Metro Area: Washington DC', 'Washington_DC']
    ]
  end


  def us_states_abrev
          [
            'AL'  ,
            'AK'  ,
            'AZ'  ,
            'AR'  ,
            'CA'  ,
            'CO'  ,
            'CT'  ,
            'DE'  ,
            'DC'  ,
            'FL'  ,
            'GA'  ,
            'HI'  ,
            'ID'  ,
            'IL'  ,
            'IN'  ,
            'IA'  ,
            'KS'  ,
            'KY'  ,
            'LA'  ,
            'ME'  ,
            'MD'  ,
            'MA'  ,
            'MI'  ,
            'MN'  ,
            'MS'  ,
            'MO'  ,
            'MT'  ,
            'NE'  ,
            'NV'  ,
            'NH'  ,
            'NJ'  ,
            'NM'  ,
            'NY'  ,
            'NC'  ,
            'ND'  ,
            'OH'  ,
            'OK'  ,
            'OR'  ,
            'PA'  ,
            'PR'  ,
            'RI'  ,
            'SC'  ,
            'SD'  ,
            'TN'  ,
            'TX'  ,
            'UT'  ,
            'VT'  ,
            'VA'  ,
            'WA'  ,
            'WV'  ,
            'WI'  ,
            'WY' 
          ]
  end
end
