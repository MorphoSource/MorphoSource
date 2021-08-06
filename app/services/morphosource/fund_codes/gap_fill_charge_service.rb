module Morphosource
  module FundCodes
    class GapFillChargeService < FundCodeChargeService
      include SolrHelper

      attr_reader :total_units_consumed_gb, :total_units_allocated_gb, 
        :billing_rate, :billing_unit, :start_date, :end_date
      attr_accessor :gap_units_gb

      def self.call(total_units_consumed_gb:, total_units_allocated_gb:, billing_rate:, billing_unit:, start_date: nil, end_date: nil)
        new( 
          total_units_consumed_gb: total_units_consumed_gb, 
          total_units_allocated_gb: total_units_allocated_gb,
          billing_rate: billing_rate, 
          billing_unit: billing_unit,
          start_date: start_date, 
          end_date: end_date
        ).call
      end

      def initialize(total_units_consumed_gb:, total_units_allocated_gb:, billing_rate:, billing_unit:, start_date: nil, end_date: nil)
        if Hyrax.config.unused_storage_fund_code_id.present? && FundCode.exists?(Hyrax.config.unused_storage_fund_code_id)
          @fund_code = FundCode.find(Hyrax.config.unused_storage_fund_code_id)
        else
          raise "Unused storage fund code not found"
        end

        @total_units_consumed_gb = total_units_consumed_gb
        @total_units_allocated_gb = total_units_allocated_gb
        @billing_rate = billing_rate
        @billing_unit = billing_unit
        @start_date = start_date
        @end_date = end_date
      end

      def call
        return fund_code_invalid_response unless validate_fund_code
        return overlapping_charge_response unless validate_no_overlapping_charges

        @gap_units_gb = total_units_allocated_gb.to_d - total_units_consumed_gb.to_d

        if gap_units_gb.present?
          amount = ( gap_units_gb.to_d * billing_rate.to_d ).round(2)
          charges = [ generate_charge(amount) ]
          
          return {
            status: 'success',
            fund_code: fund_code&.id,
            identifier: fund_code&.identifier,
            message: 'Charge(s) successfully generated',
            charges: charges
          } 
        else
          return {
            status: 'failure',
            fund_code: fund_code&.id,
            identifier: fund_code&.identifier,
            message: 'No gap fill charge possible, because no gap exists!',
            charges: []
          }
        end
      end

      def generate_charge(amount)
        charge = FundCodeCharge.new(
          fund_code: fund_code,
          description: "Storage usage charge for all unused data storage and extra data (derivatives, temp files, etc.) storage for cost object code #{fund_code.identifier} with MorphoSource title '#{fund_code.title}'",
          start_date: start_date,
          end_date: end_date,
          billing_rate: billing_rate,
          billing_unit: billing_unit,
          units_consumed: gap_units_gb,
          amount: amount,
          service_type: 'gap_fill'
        )
        charge.save!
        return charge
      end
    end
  end
end