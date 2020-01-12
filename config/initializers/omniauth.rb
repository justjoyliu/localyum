OmniAuth.config.logger = Rails.logger
AUTH_FB_KEY = fb_key
AUTH_FB_SECRET = fb_secret

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, AUTH_FB_KEY, AUTH_FB_SECRET, {:provider_ignores_state => true, :scope => 'email, offline_access, basic_info'}
end
