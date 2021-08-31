module Morphosource
  module FundCodes
    class BillingCycleService

      attr_reader :billing_rate, :billing_unit
      attr_accessor :start_date, :end_date
      attr_accessor :packrat_data

      def self.call(billing_rate: nil, billing_unit: nil, custom_start_date: nil, custom_end_date: nil)
        new(
          billing_rate: billing_rate, 
          billing_unit: billing_unit, 
          custom_start_date: custom_start_date, 
          custom_end_date: custom_end_date
        ).call
      end

      def initialize(billing_rate: nil, billing_unit: nil, custom_start_date: nil, custom_end_date: nil)
        @billing_rate = billing_rate || packrat_data[:billing_rate]
        @billing_unit = billing_unit || packrat_data[:billing_unit]
        @start_date = custom_start_date || determine_start_date
        @end_date = custom_end_date || determine_end_date
      end

      def call
        if [billing_rate, billing_unit, start_date, end_date].any? { |x| !x.present? }
          raise "One or more required parameters is not present"
        end

        special_fund_code_ids = [
          Hyrax.config.subsidizing_fund_code_id, 
          Hyrax.config.unused_storage_fund_code_id
        ].compact

        # Generate standard and external markup charges
        fund_code_responses = []
        FundCode.where.not(id: special_fund_code_ids).where(chargeable: true).each do |fc|
          fund_code_responses << FundCodeChargeService.call(
            fund_code: fc, 
            billing_rate: billing_rate, 
            billing_unit: billing_unit, 
            custom_start_date: start_date, 
            custom_end_date: end_date
          )
        end

        statuses = fund_code_responses.pluck(:status)
        if statuses.all? { |x| x == 'success' }
          status = 'success'
          message = 'One or more charges successfully generated.'
        elsif statuses.all? { |x| x == 'failure' }
          status = 'failure'
          message = 'Failure to process any charges. See individual fund code responses.'
        else
          status = 'mixed'
          message = 'One or more charges were successfully generated, but one or more charges also failed to process. See individual fund code responses.'
        end

        if status != 'failure'
          # generate charge for all subsidized data
          subsidize_charge = SubsidizeChargeService.call(
            billing_rate: billing_rate,
            billing_unit: billing_unit,
            custom_start_date: start_date,
            custom_end_date: end_date
          )

          fund_code_responses << subsidize_charge

          # generate gap-fill charge to account for all other storage
          if subsidize_charge[:status] == 'success'
            fund_code_responses << GapFillChargeService.call(
              total_units_consumed_gb: sum_storage_units_consumed(fund_code_responses),
              total_units_allocated_gb: packrat_data[:total_storage].to_d,
              billing_rate: billing_rate,
              billing_unit: billing_unit,
              start_date: start_date,
              end_date: end_date
            )
          end
        end

        return {
          status: status,
          message: message,
          fund_code_responses: fund_code_responses
        }
      end

      private

      def sum_storage_units_consumed(responses)
        responses.inject(0) do |sum, response|
          charge_storage_units_consumed_gb = ( response[:charges] || [] )
            .select { |c| c.service_type != 'external_markup'}
            .pluck(:units_consumed)
            .sum

          sum + charge_storage_units_consumed_gb
        end
      end

      def packrat_data
        @packrat_data ||= Morphosource::PackratApi.get_volume_details[:data]
      end

      def determine_start_date
        if DateTime.current.day < 24
          (DateTime.current.change(day: 25) - 2.month).to_date
        else
          (DateTime.current.change(day: 25) - 1.month).to_date
        end
      end

      def determine_end_date
        if DateTime.current.day < 24
          (DateTime.current.change(day: 24) - 1.month).to_date
        else
          DateTime.current.change(day: 24).to_date
        end
      end
    end
  end
end