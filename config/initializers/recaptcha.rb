Recaptcha.configure do |config|
  # recaptcha version2 keys:
  config.site_key  = ENV['RECAPTCHA_SITE_KEY']
  config.secret_key = ENV['RECAPTCHA_SECRET_KEY'] 
end
