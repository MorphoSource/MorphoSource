require 'rest-client'
require 'json'

# Use WordPress REST API to get posts from WordPress blog indicated in config
module Morphosource
  class WordpressBlogApi
    extend ActiveSupport::Autoload

    API_URL = Hyrax.config.wordpress_blog_url
    POSTS_ENDPOINT = 'wp-json/wp/v2/posts'

    def self.blog_url
      API_URL
    end

    def self.get_posts
      begin
        response = api_request
      rescue => e
        Rails.logger.error "WordpressBlogApi: API request to Wordpress site failed with following exception: #{e}"
        return []
      end

      if response.code == 200
        posts = JSON.parse(response.body)
        posts.map do |post|
          {
            date: Date.strptime(post['date']).to_s,
            link: post['link'],
            title: post.dig('title', 'rendered'),
            content: post.dig('content', 'rendered'),
            excerpt: post.dig('excerpt', 'rendered')
          }
        end
      else
        []
      end
    end

    def self.api_request
      RestClient.get(
        API_URL + POSTS_ENDPOINT,
        { params: { per_page: 3 } }
      )
    end
  end
end