require 'rails_helper'
require 'equivalent-xml'

RSpec.describe Hyrax::Renderers::ShowcasePageLinkAttributeRenderer do

  describe "#attribute_value_to_html" do
    subject             { Nokogiri::HTML(renderer.render) }

    context 'Renders device link' do
      let(:obj)             { FactoryBot.create(:device, title: ['Test title'], creator: ['Creator']) }
      let(:value)           { obj.id }
      let(:field)           { "Field label"}
      let(:renderer)        { described_class.new(field, value) }
      let(:expected_result) {
        "<div class='row'><div class='col-xs-6 showcase-label'>#{field}</div><div class='col-xs-6 showcase-value '><span class='showcase-link' style='word-break: normal;'><a href=\"#{Rails.application.routes.url_helpers.hyrax_device_path(obj.id)}\">#{obj.creator.first}</a></span></div></div>"
      }
      it 'displays device link ' do
        expect(renderer.render()).to eq(expected_result)
      end
    end

    context 'Renders Organization link' do
      let(:obj)             { FactoryBot.create(:organization, title: ['Test title']) }
      let(:value)           { obj.id }
      let(:field)           { "Field label"}
      let(:renderer)        { described_class.new(field, value) }
      let(:expected_result) {
        "<div class='row'><div class='col-xs-6 showcase-label'>#{field}</div><div class='col-xs-6 showcase-value '><span class='showcase-link' style='word-break: normal;'><a href=\"#{Rails.application.routes.url_helpers.hyrax_organization_path(obj.id)}\">#{obj.title.first}</a></span></div></div>"
      }
      it 'displays organization link ' do
        expect(renderer.render()).to eq(expected_result)
      end
    end

    context 'Renders Organization Collection link' do
      let(:depositor)     { FactoryBot.create(:contributor) }
      let(:obj)             { FactoryBot.create(:organization_collection, depositor: depositor.ms_id, title: ['Test title']) }
      let(:value)           { obj.id }
      let(:field)           { "Field label"}
      let(:renderer)        { described_class.new(field, value) }
      let(:expected_result) {
        "<div class='row'><div class='col-xs-6 showcase-label'>#{field}</div><div class='col-xs-6 showcase-value '><span class='showcase-link' style='word-break: normal;'><a href=\"#{Rails.application.routes.url_helpers.organization_collection_path(obj.id)}\">#{obj.title.first}</a></span></div></div>"
      }
      it 'displays organization collection link ' do
        expect(renderer.render()).to eq(expected_result)
      end
    end

    context 'Renders Media link' do
      let(:obj)             { FactoryBot.create(:media, title: ['Test title']) }
      let(:value)           { obj.id }
      let(:field)           { "Field label"}
      let(:renderer)        { described_class.new(field, value) }
      let(:expected_result) {
        "<div class='row'><div class='col-xs-6 showcase-label'>#{field}</div><div class='col-xs-6 showcase-value '><span class='showcase-link' style='word-break: normal;'><a href=\"#{Rails.application.routes.url_helpers.hyrax_media_path(obj.id)}\">#{obj.title.first}</a></span></div></div>"
      }
      it 'displays media link ' do
        expect(renderer.render()).to eq(expected_result)
      end
    end

  end

end
