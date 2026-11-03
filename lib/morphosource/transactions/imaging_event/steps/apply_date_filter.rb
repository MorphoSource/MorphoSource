# frozen_string_literal: true
module Morphosource
  module Transactions
    module ImagingEvent
      module Steps
        ##
        # A step that normalizes date fields on an imaging event ChangeSet.
        # Converts M/D/YYYY and D/M/YYYY formats to YYYY-MM-DD; passes other
        # values through unchanged; converts nil to an empty string.
        class ApplyDateFilter
          include Dry::Monads[:result]

          DATE_ATTRIBUTES = [:date_created].freeze

          ##
          # @param [Hyrax::ChangeSet] obj
          #
          # @return [Dry::Monads::Result]
          def call(obj)
            DATE_ATTRIBUTES.each do |attr|
              next unless obj.respond_to?(attr) && obj.respond_to?(:"#{attr}=")

              str = Array.wrap(obj.send(attr)).first
              obj.send(:"#{attr}=", [normalize_date(str)])
            end

            Success(obj)
          rescue StandardError => e
            Rails.logger.error("ApplyDateFilter failed: #{e.message}")
            Failure([:apply_date_filter_failed, obj])
          end

          private

          def normalize_date(str)
            case str
            when /^(\d{4})[\-\/](\d{1,2})[\-\/](\d{1,2})$/
              Date.valid_date?($1.to_i, $2.to_i, $3.to_i) ? $1 + "-" + $2.rjust(2, "0") + "-" + $3.rjust(2, "0") : str
            when /^(\d{1,2})[\-\/](\d{1,2})[\-\/](\d{4})$/
              Date.valid_date?($3.to_i, $1.to_i, $2.to_i) ? $3 + "-" + $1.rjust(2, "0") + "-" + $2.rjust(2, "0") : str
            when nil
              ''
            else
              str
            end
          end
        end
      end
    end
  end
end
