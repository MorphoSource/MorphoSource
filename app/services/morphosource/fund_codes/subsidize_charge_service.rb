module Morphosource
  module FundCodes
    class SubsidizeChargeService < FundCodeChargeService

      def self.call(billing_rate:, billing_unit:, custom_start_date: nil, custom_end_date: nil)
        new( 
          billing_rate: billing_rate, 
          billing_unit: billing_unit, 
          custom_start_date: custom_start_date, 
          custom_end_date: custom_end_date
        ).call
      end

      def initialize(billing_rate:, billing_unit:, custom_start_date: nil, custom_end_date: nil)
        if Hyrax.config.subsidizing_fund_code_id.present? && FundCode.exists?(Hyrax.config.subsidizing_fund_code_id)
          @fund_code = FundCode.find(Hyrax.config.subsidizing_fund_code_id)
        else
          raise "Subsidizing fund code not found"
        end
        
        @billing_rate = billing_rate
        @billing_unit = billing_unit
        @start_date = custom_start_date
        @end_date = custom_end_date
        @solr = solr_service.new
      end

      def initial_media_ids
        @initial_media_ids ||= query_subsidized_media_ids
      end

      def query_subsidized_media_ids
        chargeable_fund_code_media_ids = chargeable_fund_codes.each_with_object([]) do |fc, array|
          array.concat(fc.media_ids)
        end

        all_media_ids = solr.get_docs(
          nil, 
          {fq: ['has_model_ssim:Media'], fl: ['id'] }
        ).pluck('id')

        return all_media_ids - chargeable_fund_code_media_ids
      end

      def chargeable_fund_codes
        FundCode.where(chargeable: true)
      end

      def generate_charges
        amount = ( units_consumed * billing_rate.to_d ).round(2)
        [ generate_charge(amount, 'subsidize') ]
      end
    end
  end
end