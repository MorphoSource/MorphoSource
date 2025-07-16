require 'rails_helper'

RSpec.describe Hyrax::Renderers::ShowcaseDateAttributeRenderer do

  describe "#attribute_value_to_html" do
    subject                 { Nokogiri::HTML(renderer.render) }

    context 'Parsing and rendering dates' do
      let(:valid_value)                      { '2020-02-24' }
      let(:rendered_date)              { "February 24, 2020" }
      let(:field)                      { :created_date }
      let(:renderer)                   { described_class.new(field, valid_value) }

      it 'displays the correct rendered date from datepicker ' do
        expect(renderer.attribute_value_to_html(valid_value)).to eq(rendered_date)
      end

    end

    context 'Parsing and rendering dates' do
      let(:invalid_value)                      { 'foobar' }
      let(:rendered_string)              { invalid_value }
      let(:field)                      { :created_date }
      let(:renderer)                   { described_class.new(field, invalid_value) }

      it 'displays text as-is if date cannot be parsed  ' do
        expect(renderer.attribute_value_to_html(invalid_value)).to eq(rendered_string)
      end

    end

  end

end
