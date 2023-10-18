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

        # Generate standard and external markup charges (but they aren't saved yet)
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

        # Responses are in JSend format, need to assess status success
        if fund_code_responses.pluck(:status).all? { |x| x == :success } 
          additional_charges = [subsidize_charge, gap_fill_charge(fund_code_responses)]
          if additional_charges.pluck(:status).all? { |x| x == :success } 
            all_charges = fund_code_responses + additional_charges
            save_all_charges(all_charges)
            report_success(all_charges)
          else
            raise_errors(additional_charges)
          end
        else
          raise_errors(fund_code_responses)
        end
      end

      def subsidize_charge
        @subsidize_charge ||= begin
          SubsidizeChargeService.call(
            billing_rate: billing_rate,
            billing_unit: billing_unit,
            custom_start_date: start_date,
            custom_end_date: end_date
          )
        end
      end

      def gap_fill_charge(fund_code_responses)
        @gap_fill_charge ||= begin
          total_units_consumed_gb = sum_storage_units_consumed(fund_code_responses + [subsidize_charge])
          GapFillChargeService.call(
            total_units_consumed_gb: total_units_consumed_gb,
            total_units_allocated_gb: packrat_data[:total_storage].to_d,
            billing_rate: billing_rate,
            billing_unit: billing_unit,
            start_date: start_date,
            end_date: end_date
          )
        end
      end

      private

      def save_all_charges(responses)
        responses.each do |response|
          (response.dig(:data, :charges) || []).each do |charge|
            charge.save if charge.is_a?(FundCodeCharge)
          end
        end
      end

      def report_success(responses)
        {
          status: "success",
          message: "Billing cycle successfully run.",
          fund_code_responses: responses
        }
      end

      def raise_errors(responses)
        failed_responses = responses.select { |response| response[:status] == :fail }
        message = "#{failed_responses.count} attempt(s) to generate fund code charges failed. Individual failure messages: "
        failed_responses.each_with_index do |response, idx|
          message << "#{idx+1}. #{response.dig(:data, :message)} (#{ (response.dig(:data, :errors)&.values || ["No specific errors found."]).join("; ") }) "
        end
        raise message
      end

      def sum_storage_units_consumed(responses)
        responses.inject(0) do |sum, response|
          charge_storage_units_consumed_gb = ( response.dig(:data, :charges) || [] )
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