class FundCodeCharge < ApplicationRecord
  belongs_to :fund_code

  before_save :set_fund_code_remaining
  before_destroy :undo_fund_code_debit

  def self.to_csv
    CSV.generate(headers: true) do |csv|
      csv << csv_headers

      all.each do |charge|
        csv << charge.to_h(:csv).values
      end
    end
  end

  def self.csv_headers
    self.exchequer_headers + [:morphosource_fund_code_title, :morphosource_funds_remaining]
  end 

  def self.exchequer_headers
    [
      :fund_code, :description, :amount, :units_consumed, :billing_rate, :billing_unit, 
      :start_date, :end_date, :service_type
    ]
  end

  def undo_fund_code_debit
    if (
      fund_code.present? && 
      fund_code.remaining.present? && 
      amount.is_a?(BigDecimal)
    )
      fund_code.update_attribute :remaining, (fund_code.remaining + amount).round(2)
    end
  end

  def set_fund_code_remaining
    if fund_code.present? && fund_code.remaining.present?
      if amount.is_a?(BigDecimal)
        self.fund_code_remaining = (fund_code.remaining - amount).round(2)
        fund_code.update_attribute :remaining, fund_code_remaining
      else
        self.fund_code_remaining = fund_code.remaining
      end
    end
  end

  def to_h(format=:exchequer)
    if format == :csv
      headers = self.class.csv_headers
    else
      headers = self.class.exchequer_headers
    end

    headers.map do |field|
      if field == :fund_code
        [ field, send(field).identifier ]
      elsif field == :morphosource_fund_code_title
        [ field, send(:fund_code).title ]
      elsif field == :morphosource_funds_remaining
        [ field, send(:fund_code_remaining).present? ? ( '%.2f' % send(:fund_code_remaining) ) : nil ]
      elsif field == :amount
        [ field, send(:amount).present? ? ( '%.2f' % send(:amount) ) : nil ]
      else
        [ field, send(field) ]
      end
    end.to_h
  end

  def as_json(options={})
    to_h
  end
end
