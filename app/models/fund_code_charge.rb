class FundCodeCharge < ApplicationRecord
  belongs_to :fund_code

  def self.to_csv
    CSV.generate(headers: true) do |csv|
      csv << csv_headers

      all.each do |charge|
        csv << charge.to_h(:csv).values
      end
    end
  end

  def self.csv_headers
    self.exchequer_headers + [:amount]
  end 

  def self.exchequer_headers
    [
      :fund_code, :description, :units_consumed, :billing_rate, :billing_unit, 
      :start_date, :end_date, :service_type
    ]
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
      else
        [ field, send(field) ]
      end
    end.to_h
  end

  def as_json(options={})
    to_h
  end
end
