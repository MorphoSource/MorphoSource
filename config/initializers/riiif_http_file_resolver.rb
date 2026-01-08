require "net/http"

Rails.application.config.to_prepare do
  Riiif::HTTPFileResolver::RemoteFile.class_eval do
    private

    def download_file
      ensure_cache_path(::File.dirname(file_name))
      benchmark("Riiif downloaded #{url}") do
        ::File.atomic_write(file_name, cache_path) do |local|
          begin
            open_with_redirects(url) do |remote|
              remote.read_body do |chunk|
                local.write(chunk)
              end
            end
          rescue OpenURI::HTTPError, Net::HTTPError => e
            raise ImageNotFoundError, e.message
          end
        end
      end
    end

    def download_opts
      opts = basic_auth_credentials ? { http_basic_authentication: basic_auth_credentials } : {}
      headers = { "User-Agent" => "MorphoSource/5" }
      headers.merge!(MorphosourceHelper.deepblue_headers_for(url))
      opts.merge(headers)
    end

    def open_with_redirects(request_url, limit = 5, &block)
      raise OpenURI::HTTPError.new("Too many redirects", nil) if limit <= 0

      uri = URI.parse(request_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      request = Net::HTTP::Get.new(uri)
      request_headers_for(request_url).each { |key, value| request[key] = value }
      if basic_auth_credentials
        user, password = basic_auth_credentials
        request.basic_auth(user, password)
      end

      http.request(request) do |response|
        case response
        when Net::HTTPRedirection
          location = response["location"]
          return open_with_redirects(location, limit - 1, &block)
        when Net::HTTPSuccess
          return block.call(response)
        else
          raise OpenURI::HTTPError.new(response.message, response)
        end
      end
    end

    def request_headers_for(request_url)
      headers = { "User-Agent" => "MorphoSource/5" }
      headers.merge!(MorphosourceHelper.deepblue_headers_for(request_url))
      headers
    end
  end
end
