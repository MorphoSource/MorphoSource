class ApiKeyStrategy < Warden::Strategies::Base
    def valid?
      api_key.present?
    end
  
    def authenticate!
      user = User.find_by(token: api_key)
  
      if user
        success!(user)
      else
        fail!('Invalid email or password')
      end
    end
  
    private
  
    def api_key
      env['HTTP_AUTHORIZATION'].to_s
    end
  end