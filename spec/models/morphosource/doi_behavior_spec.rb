require 'rails_helper'

RSpec.describe Morphosource::DoiBehavior do
  let(:media_list)  { FactoryBot.create(:media_list, title: ['media list title'], depositor: depositor.ms_id, doi: doi) }
  let(:depositor)   { User.create(email: "depositor@email.com", password: 'password', display_name: 'DepositorFirst DepositorLast') }
  let(:media)       { Media.create(title: ['media title'], depositor: depositor.ms_id, doi: doi) }
  let(:doi)         { [] }
  let(:target_url)  { 'http://example.com' }

  describe '#prevent_doi_deletion' do
    context 'when DOI is present' do
      let(:doi) { ['10.1234/existing.doi'] }

      it 'prevents deletion by throwing :abort' do
        expect { media_list.destroy }.to_not change { MediaList.exists?(media_list.id) }
        expect { media.destroy }.to_not change { Media.exists?(media.id) }
      end
    end

    context 'when DOI is empty' do
      let!(:doi) { [] }

      it 'allows deletion to proceed' do
        expect { media_list.destroy! }.to change { MediaList.exists?(media_list.id) }.from(true).to(false)
        expect { media.destroy! }.to change { Media.exists?(media.id) }.from(true).to(false)
      end
    end
  end

  describe '#verify_creator' do
    let(:organization)  { FactoryBot.create(:organization_collection, title: ['Test Org'], depositor: depositor.ms_id) }
    let(:doi)           { [] }
    let(:media_list)    { FactoryBot.create(:media_list, title: ['media list title'], depositor: depositor.ms_id, creator: creator, doi: doi) }
    let(:media)         { Media.create(title: ['media title'], depositor: depositor.ms_id, doi: doi, owner: owner) }

    context 'when creator is a valid User' do
      let(:creator)   { [depositor.ms_id] }
      let(:owner)     { depositor.ms_id }

      it 'returns the User object' do
        expect(media_list.send(:verify_creator)).to eq(depositor)
        expect(media.send(:verify_creator)).to eq(depositor)
      end
    end

    context 'when creator is a valid OrganizationCollection' do
      let(:creator) { [organization.id] }
      let(:owner)   { organization.id }

      it 'returns the OrganizationCollection object' do
        expect(media_list.send(:verify_creator)).to eq(organization)
        expect(media.send(:verify_creator)).to eq(organization)
      end
    end

    context 'when creator is invalid' do
      let(:owner)   { 'invalid' }
      let(:creator) { ['invalid'] }

      before do
        media.depositor = 'invalid'
        media.save(validate: false)
      end

      it 'returns nil' do
        expect(media_list.send(:verify_creator)).to be_nil
        expect(media.send(:verify_creator)).to be_nil
      end
    end
  end

  describe '#mint_doi' do
    let(:media)       { Media.create(title: ['media title'], depositor: depositor.ms_id, doi: doi) }
    let(:media_list)  { FactoryBot.create(:media_list, title: ['media list title'], depositor: depositor.ms_id, creator: [depositor.ms_id], doi: doi) }
    let(:doi)         { [] }

    context 'when DOI exists' do
      let(:doi) { ['10.1234/existing.doi'] }

      it 'returns a standard error' do
        expect(media_list.mint_doi(target_url)).to be_a(StandardError)
        expect(media_list.mint_doi(target_url).message).to eq("DOI already exists")
        expect(media.mint_doi(target_url)).to be_a(StandardError)
        expect(media.mint_doi(target_url).message).to eq("DOI already exists")
      end
    end

    context 'when creator is missing' do
      before do
        media_list.creator = []
        media_list.save!
        media.depositor = 'invalid'
        media.owner = 'invalid'
        media.save!(validate: false)
      end
      it 'returns a standard error' do
        expect(media_list.mint_doi(target_url)).to be_a(StandardError)
        expect(media_list.mint_doi(target_url).message).to eq("Creator user or organization was not found")

        expect(media.mint_doi(target_url)).to be_a(StandardError)
        expect(media.mint_doi(target_url).message).to eq("Creator user or organization was not found")
      end
    end

    context 'when creator display name is empty' do
      let(:organization)  { FactoryBot.create(:organization_collection, title: ['Test Org'], depositor: depositor.ms_id) }
      before do
        organization.title = []
        organization.save!(validate: false)
        media_list.creator = [organization.id]
        media_list.save!
        media.owner = organization.id
        media.save!(validate: false)
      end

      it 'returns a standard error' do
        expect(media_list.mint_doi(target_url)).to be_a(StandardError)
        expect(media_list.mint_doi(target_url).message).to eq("Creator display name is nil")

        expect(media.mint_doi(target_url)).to be_a(StandardError)
        expect(media.mint_doi(target_url).message).to eq("Creator display name is nil")
      end
    end

    context 'when object is a Media' do
      it 'calls mint_media_doi' do
        expect(media).to receive(:mint_media_doi)
        media.mint_doi(target_url)
      end
    end

    context 'when object is a MediaList' do
      it 'calls mint_list_doi' do
        expect(media_list).to receive(:mint_list_doi)
        media_list.mint_doi(target_url)
      end
    end

    context 'doi is successfully minted' do
      let(:new_doi) { '10.5072/FK2/MYSAMPLEDOI' }

      before do
        allow(media).to receive(:mint_media_doi).and_return(new_doi)
        allow(media_list).to receive(:mint_list_doi).and_return(new_doi)
      end
      it 'assigns and saves the new DOI' do
        expect(media.mint_doi(target_url)).to eq(new_doi)
        expect(media.doi).to eq([new_doi])
        expect(media_list.mint_doi(target_url)).to eq(new_doi)
        expect(media_list.doi).to eq([new_doi])
      end
    end
  end

  describe 'mint_media_doi' do
    let(:media)       { Media.create(title: ['media title'], depositor: depositor.ms_id, doi: [], media_type: ["Mesh"]) }
    let(:target_url)  { 'http://example.com/media/1' }


    let(:params) {
                    {
                      "title"=> media.title.first,
                      "url"=> target_url,
                      "author_first"=> "DepositorFirst",
                      "author_last"=> "DepositorLast",
                      "resource_type"=> media.media_type.first
                    }
                  }

    before do
      media.instance_variable_set(:@creator, depositor)
      media.instance_variable_set(:@target_url, target_url)
    end


    it 'calls Morphosource::CrossrefDoiMinter.mint_doi with correct parameters' do

      expect(Morphosource::CrossrefDoiMinter).to receive(:mint_doi).with(media.id, params)

      media.send(:mint_media_doi)
    end
  end

  describe 'mint_list_doi' do
    let(:contributor1)  { User.create(email: "contributor1@example.com", password: "password", display_name: "ContributorFirst ContributorLast") }
    let(:contributor2)  { User.create(email: "contributor2@example.com", password: "password", display_name: "Contributor2First Contributor2Last") }
    let(:media_list)    { FactoryBot.create(:media_list, title: ['media title'], depositor: depositor.ms_id, doi: [], creator: [depositor.ms_id], contributor: [contributor1.ms_id, contributor2.ms_id]) }
    let(:media1)        { Media.create(title: ['Media1'], depositor: depositor.ms_id, media_type: ["Mesh"], doi: media_doi ) }
    let(:media2)        { Media.create(title: ['Media2'], depositor: depositor.ms_id, media_type: ["Mesh"], doi: media_doi ) }
    let(:media3)        { Media.create(title: ['Media3'], depositor: depositor.ms_id, media_type: ["Image"], doi: media_doi ) }

    before do
      media_list.instance_variable_set(:@creator, depositor)
      media_list.instance_variable_set(:@target_url, target_url)
      media_list.add_member_objects([media1, media2, media3])
    end

    context 'list media do not have DOIs' do
      let(:media_doi) { [] }

      it 'raises a StandardError' do
        expect { media_list.send(:mint_list_doi) }.to raise_error(StandardError, "MediaList #{media_list.id} has media without DOIs: #{media1.id}, #{media2.id}, #{media3.id}")
      end
    end

    context 'list media have DOIs' do
      let(:media_doi)     { ['10.1234/FK2/MYSAMPLEDOI1'] }

      let(:contributors)  {  [
                              {
                                "contributor_first" => "Contributor2First",
                                "contributor_last" => "Contributor2Last"
                              },
                              {
                                "contributor_first" => "ContributorFirst",
                                "contributor_last" => "ContributorLast"
                              }
                          ] }

      let(:child_media)  {  [
                            {
                              "doi" => media_doi.first
                            },
                            {
                              "doi" => media_doi.first
                            },
                            {
                              "doi" => media_doi.first
                            }
                        ]}

      it 'calls Morphosource::CrossrefListDoiMinter.mint_doi with correct parameters' do

        expect(Morphosource::CrossrefDoiMinter).to receive(:mint_doi) do |id, params|
          expect(id).to eq(media_list.id)

          expect(params["title"]).to eq(media.title.first)
          expect(params["url"]).to eq(target_url)
          expect(params["author_first"]).to eq("DepositorFirst")
          expect(params["author_last"]).to eq("DepositorLast")

          expect(params["contributors"]).to match_array(contributors)
          expect(params["child_media"]).to match_array(child_media)
        end

        media_list.send(:mint_list_doi)
      end
    end
  end
end
