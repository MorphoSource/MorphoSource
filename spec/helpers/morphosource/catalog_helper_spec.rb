require 'rails_helper'

RSpec.describe Morphosource::CatalogHelper, type: :helper do
  include Rails.application.routes.url_helpers

  describe 'link_to_object' do
    let(:args)  { { document: { "physical_object_id_tesim" => ["123456789"], "physical_object_title_tesim" => ["title"]  } } }

    context 'object is a bso' do
      let(:bso_args) { { document: args[:document].merge( "media_physical_object_type_tesim" => ["Biological Specimen"] ) } }

      it 'returns a link to the bso' do
        expect(helper.link_to_object(bso_args)).to eq("<a href=\"/concern/biological_specimens/123456789\">title</a>")
      end
    end

    context 'object is a cho' do
      let(:cho_args) { { document: args[:document].merge( "media_physical_object_type_tesim" => ["Cultural Heritage Object"] ) } }

      it 'returns a link to the cho' do
        expect(helper.link_to_object(cho_args)).to eq("<a href=\"/concern/cultural_heritage_objects/123456789\">title</a>")
      end
    end
  end

  describe 'link_to_user_with_ownership' do
    let(:owner_name)  { "Owner Name" }
    let(:owner_id)    { "1234" }
    let(:args) { { value: [owner_id], document: {} } }

    context 'media has a user with ownership and name' do
      context 'owner is a user' do
        let(:args2) { args.merge(document: { "user_with_ownership_name_tesim" => [owner_name] } ) }

        it 'returns a link to the owner with their name' do
          expect(helper.link_to_user_with_ownership(args2)).to eq("<a href=\"/users/#{owner_id}\">#{owner_name}</a>")
        end
      end

      context 'owner is an organization collection' do
        let(:args2) { args.merge(document: { "user_with_ownership_name_tesim" => [owner_name], "owner_type_ssi" => "OrganizationCollection" } ) }

        it 'returns a link to the organization with its title' do
          expect(helper.link_to_user_with_ownership(args2)).to eq("<a href=\"/organizations/#{owner_id}\">#{owner_name}</a>")
        end
      end
    end

    context 'meda has a user with ownership but no name' do
      it 'returns a link to the owner with unknown user name' do
        expect(helper.link_to_user_with_ownership(args)).to eq("<a href=\"/users/1234\">User Name Unknown</a>")
      end
    end

    context 'media does not have a depositor or owner' do
      let(:args3) { {} }

      it 'returns nil' do
        expect(helper.link_to_user_with_ownership(args3)).to eq(nil)
      end
    end
  end
end
