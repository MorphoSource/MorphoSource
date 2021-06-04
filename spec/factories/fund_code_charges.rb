FactoryBot.define do
  factory :fund_code_charge do
    references ""
    description "MyText"
    start_date "2021-04-29"
    end_date "2021-04-29"
    billing_rate "9.99"
    billing_unit "MyString"
    units_consumed "9.99"
    amount "9.99"
    service_type "MyString"
  end
end
