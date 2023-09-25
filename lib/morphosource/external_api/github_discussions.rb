# frozen_string_literal: true

require 'rest-client'
require 'json'

# Use GitHub GraphQL API to query MorphoSource Community discussion announcements
module Morphosource
  module ExternalApi
    class GithubDiscussions
      extend ActiveSupport::Autoload
      include Morphosource::Jsend

      API_URL = "https://api.github.com/graphql"
      DSC_NUM = 3
      TOKEN = Hyrax.config.github_access_token
      ANNOUNCEMENTS_CATEGORY_ID = "DIC_kwDOBoWZes4CVD_o"
      MD_RENDERER = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
      ::RestClient.log = Rails.logger

      def self.get_announcements
        response = execute_request
        process_response(response)
      rescue RestClient::BadRequest => e
        RestClient.log.error("GitHub GraphQL API returned 400 Bad Request")
        jsend_fail({ "message" => e.message })
      rescue RestClient::Exceptions::Timeout => e
        RestClient.log.error("Github GraphQL API timed out")
        jsend_error(e)
      rescue StandardError => e
        RestClient.log.error("GitHub GraphQL API returned #{e.message}")
        jsend_error(e)
      end

      def self.execute_request
        RestClient::Request.execute(
          method:  :post, 
          url:     API_URL,
          payload: graphql_query.to_json,
          headers: { 
            Authorization: "bearer #{ TOKEN }",
          },
          timeout: 10
        )
      end

      def self.process_response(response)
        return jsend_fail({ "message" => "Response code: #{response.code}" }) unless response.code == 200

        data = parse_response(response)
        if data.key?("errors")
          jsend_fail(data["errors"])
        else
          jsend_success(process_announcements(data))
        end
      rescue StandardError => e
        jsend_error(e, "Response.body parsing failed with exception: #{e.message}.")
      end

      def self.parse_response(response)
        force_encoding(response)
        JSON.parse(response.body)
      end

      def self.force_encoding(response)
        response.body.force_encoding('utf-8').to_json({ content_type: :json, accept: :json })
      end

      def self.process_announcements(data)
        if (posts = data.dig("data", "repository", "discussions", "nodes")).present?
          posts.map do |post|
            {
              title: post["title"] || "Unknown Title",
              date: format_date(post["createdAt"]),
              excerpt: format_body(post["body"]),
              url: post["url"]
            }
          end
        else
          []
        end
      end

      def self.format_date(date)
        DateTime.strptime(date).strftime("%Y-%m-%d")
      rescue StandardError => e
        "Unknown Date"
      end

      def self.format_body(body)
        MD_RENDERER.render(ActionController::Base.helpers.truncate(body, length: 250))
      end

      def self.graphql_query
        {
          "query" => "
          {
            repository(owner: \"MorphoSource\", name: \"Community\") {
              discussions(first: #{DSC_NUM}, categoryId: \"#{ANNOUNCEMENTS_CATEGORY_ID}\") {
                nodes {
                  title
                  createdAt
                  body
                  url
                }
              }
            }
          }
          "
        }
      end
    end
  end
end