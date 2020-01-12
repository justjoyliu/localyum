ActionMailer::Base.smtp_settings = {
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :domain               => "localyum.me",
  :user_name            => secret_user_name,
  :password             => secret_pw,
  :authentication       => "plain",
  :enable_starttls_auto => true
}