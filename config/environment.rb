# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
HostSample::Application.initialize!

# ActionMailer::Base.default_content_type = "text/html"
ActionMailer::Base.default :content_type => "text/html"