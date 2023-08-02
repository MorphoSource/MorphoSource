require 'rails_helper'

RSpec.describe Morphosource::CatalogHelper, type: :helper do
  include Rails.application.routes.url_helpers

  describe 'link_to_object' do
    let(:args)  { { document: { "physical_object_id_tesim" => [object.id] } } }

    context 'object is a bso' do
      let!(:object)  { BiologicalSpecimen.create(title: ['title'], vouchered: ['Yes']) }

      it 'returns a link to the bso' do
        expect(helper.link_to_object(args)).to eq("<a href=\"/concern/biological_specimens/#{object.id}\">title</a>")
      end
    end

    context 'object is a cho' do
      let!(:object)  { CulturalHeritageObject.create(title: ['title'], vouchered: ['Yes']) }

      it 'returns a link to the cho' do
        expect(helper.link_to_object(args)).to eq("<a href=\"/concern/cultural_heritage_objects/#{object.id}\">title</a>")
      end
    end
  end

  describe 'link_to_user_with_ownership' do
    let(:depositor) { User.create(email: 'depositor@email.com', password: 'password', display_name: 'Depositor') }
    let(:owner)     { User.create(email: 'owner@email.com', password: 'password', display_name: 'Owner') }
    let(:args)      { { document: SolrDocument.find(media.id) } }


    context 'media has an owner and depositor' do
      let!(:media)  { Media.create(title: ['title'], depositor: depositor.ms_id, owner: owner.ms_id) }

      it 'returns a link to the owner' do
        expect(helper.link_to_user_with_ownership(args)).to eq("<a href=\"/users/#{owner.ms_id}\">#{owner.name}</a>")
      end
    end

    context 'media has a depositor only' do
      let!(:media)  { Media.create(title: ['title'], depositor: depositor.ms_id) }

      it 'returns a link to the depositor' do
        expect(helper.link_to_user_with_ownership(args)).to eq("<a href=\"/users/#{depositor.ms_id}\">#{depositor.name}</a>")
      end

      context 'depositor does not have a display name set' do
        let(:depositor) { User.create(email: 'depositor@email.com', password: 'password') }

        it 'returns a link to the depositor' do
          expect(helper.link_to_user_with_ownership(args)).to eq("<a href=\"/users/#{depositor.ms_id}\">#{depositor.email}</a>")
        end
      end
    end

    context 'media does not have a depositor or owner' do
      let!(:media)  { Media.create(title: ['title']) }

      it 'returns nil' do
        expect(helper.link_to_user_with_ownership(args)).to eq(nil)
      end
    end
  end
end
