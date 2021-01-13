require 'rails_helper'
require 'equivalent-xml'

RSpec.describe Hyrax::Renderers::ShowcaseDefaultAttributeRenderer do

  describe "#render" do
    subject                 { Nokogiri::HTML(renderer.render) }

    context 'Display decimal with significant digits' do
      let(:value)                      { '0.123456789' }
      let(:rendered_default)              {  "<div class='row'><div class='col-xs-6 showcase-label'>My field</div><div class='col-xs-6 showcase-value '>0.123</div></div>" }
      let(:rendered_signif)              {  "<div class='row'><div class='col-xs-6 showcase-label'>My field</div><div class='col-xs-6 showcase-value '>0.123457</div></div>" }
      let(:field)                      { :my_field }
      let(:renderer)                   { described_class.new(field, value) }
      let(:renderer_with_signif_digits)                   { described_class.new(field, value, signif_digits: 6) }

      it 'displays number with default significant digit count ' do
        expect(renderer.render()).to eq(rendered_default)
      end

      it 'displays number with specified significant digit count ' do
        expect(renderer_with_signif_digits.render()).to eq(rendered_signif)
      end

    end


  end

end
