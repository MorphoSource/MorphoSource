module Morphosource
  module FundCodes
    class GapFillChargeService < FundCodeChargeService
      include SolrHelper

      attr_reader :total_units_consumed_gb, :total_units_allocated_gb, 
        :billing_rate, :billing_unit, :start_date, :end_date, :save_charge
      attr_accessor :gap_units_gb

      def self.call(total_units_consumed_gb:, total_units_allocated_gb:, billing_rate:, billing_unit:, start_date: nil, end_date: nil, save_charge: false)
        new( 
          total_units_consumed_gb: total_units_consumed_gb, 
          total_units_allocated_gb: total_units_allocated_gb,
          billing_rate: billing_rate, 
          billing_unit: billing_unit,
          start_date: start_date, 
          end_date: end_date,
          save_charge: save_charge
        ).call
      end

      def initialize(total_units_consumed_gb:, total_units_allocated_gb:, billing_rate:, billing_unit:, start_date: nil, end_date: nil, save_charge: false)
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
        @save_charge = save_charge
      end

      def call
        return fund_code_invalid_response unless validate_fund_code
        return overlapping_charge_response unless validate_no_overlapping_charges

        @gap_units_gb = total_units_allocated_gb.to_d - total_units_consumed_gb.to_d
        return fund_code_incoherent_charge_response unless validate_charge_sanity

        amount = ( gap_units_gb.to_d * billing_rate.to_d ).round(2)
        charges = [ generate_charge(amount) ]

        return jsend_success({
          fund_code: fund_code&.id,
          identifier: fund_code&.identifier,
          message: "One or more charges successfully generated.",
          charges: charges
        })        
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
        charge.save! if save_charge
        return charge
      end

      def validate_charge_sanity
        gap_units_gb.present? &&
        gap_units_gb >= 0.to_i && 
        billing_rate.to_d >= 0.to_d
      end

      def fund_code_incoherent_charge_response
        errors = {}
        errors[:gap_units_gb] = "Gap units GB must be present." if !(gap_units_gb.present?)
        if gap_units_gb.present?
          errors[:gap_units_gb] = "Gap units GB can not be negative." if !(gap_units_gb >= 0.to_i)
        end
        errors[:billing_rate] = "Billing rate can not be negative." if !(billing_rate.to_d >= 0.to_d)
        
        jsend_fail({
          errors: errors,
          fund_code: fund_code&.id,
          fund_code_identifier: fund_code&.identifier,
          message: "Could not generate gap fill charge, gap units GB or billing rate are negative."
        })
      end
    end
  end
end