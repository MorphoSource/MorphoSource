class ETagMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)
    # add an ETag header for non-download response and if ETag isn't already present
    unless (env["REQUEST_PATH"] == "/download") || headers['ETag']
      body = ""
      response.each { |part| body += part }
      etag = Digest::MD5.hexdigest(body)
      headers['ETag'] = etag
    end

    [status, headers, response]
  end
end
