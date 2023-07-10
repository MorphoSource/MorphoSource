require 'rest-client'
require 'json'

# Google Analytics API v4 (GA) interface library
# TODO: Deprecate and replace this once Hyrax 3.x/4.x and/or Legato support GA4 fully
module Morphosource
  module ExternalApi
    class Ga4
      extend ActiveSupport::Autoload
      include Hyrax::Analytics::Ga4

      ::RestClient.log = Rails.logger

      def self.page_views(start_date:, end_date:, limit: 10_000, offset: 0, paths: [])
        new.page_views(
          start_date: start_date, 
          end_date: end_date, 
          limit: limit, 
          offset: offset, 
          paths: paths
        )
      end

      def initialize
        @property_id = self.class.config.analytics_id
        raise "Google Analytics 4 property ID not present in config/analytics.yml" if !@property_id.present?

        @token = self.class.token
        raise "Google Analytics 4 access token not successfully generated" if !@token.present?
      end

      def page_views(start_date:, end_date:, limit: 10_000, offset: 0, paths: [])
        @start_date = start_date.to_date
        @end_date = end_date.to_date
        @limit = limit
        @offset = offset
        @paths = paths
        errors = []

        begin
          response = RestClient::Request.execute(
            method: :post,
            url: "https://analyticsdata.googleapis.com/v1beta/properties/#{@property_id}:runReport",
            payload: page_views_payload.to_json,
            headers: {
              authorization: "Bearer #{@token.token}",
              accept: "application/json",
              content_type: "application/json"
            },
            timeout: 15
          )
        rescue RestClient::Exceptions::Timeout => exception
          Rails.logger.error(exception)
          errors << "GA4 API request timed out: #{exception.message}"
        rescue => exception
          Rails.logger.error(exception)
          errors << "GA4 API request failed to complete: #{exception.message}"
        end

        if response.code == 200
          begin
            body = JSON.parse(response.body)
            return {
              status: :success,
              data: {
                count: body["rowCount"] || 0,
                views: (body["rows"] || []).map do |row|
                  OpenStruct.new(
                    pageviews: row["metricValues"][0]["value"],
                    date: row["dimensionValues"][0]["value"],
                    page_path: row["dimensionValues"][1]["value"]
                  )
                end
              }
            }
          rescue => exception
            Rails.logger.error(exception)
            errors << "Error parsing GA4 API response: #{exception.message}"
          end
        else
          errors << "GA4 API request failed with status code #{response.code} and response body #{response.body}"
        end

        if errors.present?
          Rails.logger.error("GA4 API request failed with one or more errors: #{errors.join("; ")}")
          return {
            status: :error,
            message: errors.join("; "),
            data: {
              messages: errors
            }
          }
        end
      end

      def page_views_payload
        {
          dimensions: [ { name: "date"}, { name: "pagePath"} ],
          metrics: [ { name: "screenPageViews"} ],
          dateRanges: [ { startDate: @start_date.to_s, endDate: @end_date.to_s } ],
          limit: @limit,
          offset: @offset,
          orderBys: [ { dimension: { orderType: "NUMERIC", dimensionName: "date" } } ]
        }.merge(@paths.present? ? dimension_filter : {} )
      end

      def dimension_filter
        { dimensionFilter: { orGroup: { expressions: @paths.map do |path|
          {
            filter: {
              fieldName: "pagePath",
              stringFilter: {
                matchType: "CONTAINS",
                value: path
              }
            }
          }
        end } } }
      end
    end
  end
end
