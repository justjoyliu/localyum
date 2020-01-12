class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :check_uri

  include SessionsHelper
  # http_basic_authenticate_with :name => "iwanttotry", :password => "iknowjoy"  

  def check_uri
  	if current_user.nil? and !/^www/.match(request.host) and !/^localhost/.match(request.host)
  		redirect_to request.protocol + "www." + request.host_with_port + request.fullpath
  	end
  end
end
