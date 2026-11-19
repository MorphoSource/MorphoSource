# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
#
# Symbols match any parameter whose name contains them, so :token covers access_token,
# refresh_token and the token param of the OAuth revoke/introspect endpoints, and :secret
# covers client_secret. These also mask matching attributes in ActiveRecord #inspect output
# (e.g. User#token, the user's API key).
#
# The OAuth authorization code is matched exactly, so unrelated params that merely contain
# "code" (fund_code, zip_code, ...) still appear in logs.
Rails.application.config.filter_parameters += [
  :password,
  :secret,
  :token,
  :code_verifier,
  /\Acode\z/
]
