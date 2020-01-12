source 'https://rubygems.org'

gem 'rails', '3.2.18'
# gem 'rails', '4.1.0'
# gem 'railties' gem install railties
# gem 'activeresource' # gem install activeresource
# gem 'bootstrap-sass', '2.1'
# gem 'bootstrap-sass', '~> 2.3.2.1'

gem 'bcrypt-ruby', '3.0.1' #password encryption
gem 'faker', '1.0.1' #to create fake users in bulk
gem 'will_paginate', '3.0.3' #to paginate for user index page
gem 'bootstrap-will_paginate', '0.0.6' #to paginate for user index page
gem 'jquery-rails'#, '2.0.2'

#for inline validation for sign up
#gem 'client_side_validations' 
gem 'simple_form'
#gem 'formtastic'
gem 'client_side_validations'
# gem 'client_side_validations-simple_form' removed when updated rails to 4.0
#gem 'client_side_validations-formtastic'

gem 'mysql2'

#gem "mini_magick"
#gem 'image_sorcery'
#gem 'rmagick'
# gem 'paperclip', '3.3.1'
gem "paperclip", "~> 4.3"#, :path => "/usr/local/bin/" #for image upload
#gem "cocaine", "= 0.3.2" 

gem 'validates_timeliness', '~> 3.0'
#gem 'calendar_date_select', :git => 'http://github.com/paneq/calendar_date_select.git', :branch => 'rails3test' 

# for map
  # ran gem install geocoder first
  # ran gem install gmaps4rails
  # ran rails generate gmaps4rails:install
  gem "geocoder"
  gem 'gmaps4rails', '1.5.6'

# for email
  # ran first gem install actionmailer
  gem "actionmailer"#, "~> 3.2.13"

# for payments
  # $ gem install sinatra braintree shotgun
  # gem 'braintree', '>= 2.16.0'
  # gem 'stripe', :git => 'https://github.com/stripe/stripe-ruby'
  gem 'stripe'
  gem 'stripe_event'

#ec2 node.js replacement
  # gem 'therubyracer', '0.12.0'
  gem 'therubyracer'
  
# for phase 2 sharing
  # not using gem 'shareable'

# for ie compatibility
  gem "useragent", "~> 0.8.3"

# for social sharing
  gem 'meta-tags', :require => 'meta_tags'

# for facebook login
  gem 'omniauth-facebook', '>= 1.5.0'
  # gem 'omniauth-facebook', '1.4.0'
  
  gem 'coffee-rails' #, '3.2.2'
  
group :development, :test do
  #gem 'sqlite3', '1.3.5'
  gem 'rspec-rails', '2.11.0'
  gem 'guard-rspec', '1.2.1'
  gem 'guard-spork', '1.2.0'  
  gem 'spork', '0.9.2'
end

group :development do
  gem 'annotate', '2.5.0'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'#,   '3.2.5'
  
  gem 'uglifier', '1.2.3'

  #for multiple file uploads
  gem 'jquery-fileupload-rails'
end

group :test do
  gem 'capybara', '1.1.2'
  gem 'factory_girl_rails', '4.1.0'
  gem 'cucumber-rails', '1.2.1', :require => false
  gem 'database_cleaner', '0.7.0'
  # gem 'launchy', '2.1.0'
  # gem 'rb-fsevent', '0.9.1', :require => false
  # gem 'growl', '1.0.3'
  gem 'turn', '0.8.2', :require => false # Pretty printed test output
end

group :production do
  gem 'pg', '0.12.2'
end
