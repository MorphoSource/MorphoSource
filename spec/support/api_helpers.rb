# spec/support/api_helpers.rb
module ApiHelpers
  def self.external_api_is_up?(url)
    response = RestClient.get(url)
    response.code == 200
  rescue
    false
  end
end