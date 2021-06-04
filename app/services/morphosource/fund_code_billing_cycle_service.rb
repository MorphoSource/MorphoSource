module Morphosource
  class FundCodeBillingCycleService

    attr_reader :billing_rate, :billing_unit
    attr_accessor :start_date, :end_date

    def self.call(billing_rate, billing_unit, custom_start_date = nil, custom_end_date = nil)
      new(billing_rate, billing_unit, custom_start_date, custom_end_date).call
    end

    def initialize(billing_rate, billing_unit, custom_start_date = nil, custom_end_date = nil)
      @billing_rate = billing_rate
      @billing_unit = billing_unit
      @start_date = custom_start_date
      @end_date = custom_end_date
    end

    def call
      fund_code_responses = []
      response_success = true
      FundCode.where(chargeable: true).each do |fc|
        response = FundCodeChargeService.call(fc, billing_rate, billing_unit, start_date, end_date)
        fund_code_responses << response
        response_success = false if response[:status] == 'failure'
      end

      if response_success
        status = 'success'
        message = 'One or more charges successfully generated'
      else
        status = 'failure'
        message = 'Failure to process one or more charges. See individual fund code responses.'
      end

      return {
        status: status, 
        message: message,
        fund_codes: fund_code_responses
      }
    end

    private

    def start_date
      @start_date ||= determine_start_date
    end

    def determine_start_date
      if DateTime.current.day < 24
        (DateTime.current.change(day: 25) - 2.month).to_date
      else
        (DateTime.current.change(day: 25) - 1.month).to_date
      end
    end

    def end_date
      @end_date ||= determine_end_date
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