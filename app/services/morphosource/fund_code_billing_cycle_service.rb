module Morphosource
  class FundCodeBillingCycleService

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

      fund_code_responses = []
      FundCode.where(chargeable: true).each do |fc|
        fund_code_responses << FundCodeChargeService.call(fc, billing_rate, billing_unit, start_date, end_date)
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

      return {
        status: status,
        message: message,
        fund_code_responses: fund_code_responses
      }
    end

    private

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