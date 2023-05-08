class ETagMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)

    # Only add an ETag header if one isn't already present
    unless headers['ETag']
      body = ""
      response.each { |part| body += part }
      etag = Digest::MD5.hexdigest(body)
      headers['ETag'] = etag
    end

    [status, headers, response]
  end
end
