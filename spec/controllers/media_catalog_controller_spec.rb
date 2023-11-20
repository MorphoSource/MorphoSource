require 'rails_helper'
include ActionDispatch::TestProcess

RSpec.describe MediaCatalogController, :type => :controller do
  describe 'Blacklight Configuration' do
    let(:config) { described_class.new.blacklight_config }

    it 'is the hyrax catalog search builder' do
      expect(config.search_builder_class).to eq(Morphosource::Catalog::MediaCatalogSearchBuilder)
    end

    it 'has a thumbnail field' do
      expect(config.index.thumbnail_field).to eq('thumbnail_path_ss')
    end

    describe 'facet fields' do
      let(:facet_fields) { config.facet_fields }

      it 'has 18 facet fields' do
        expect(facet_fields.count).to eq(19)
      end

      describe 'human readable media type' do
        subject { facet_fields["media_type"] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Media Type")
          expect(subject.limit).to eq(10)
        end
      end

      describe 'modality' do
        subject { facet_fields["modality"] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Modality")
          expect(subject.limit).to eq(10)
        end
      end

      describe 'physical object type' do
        subject { facet_fields["object_type"] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Object Type")
          expect(subject.limit).to eq(10)
        end
      end

      describe 'organization' do
        subject { facet_fields["organization"] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Organization")
          expect(subject.limit).to eq(10)
        end
      end

      describe 'imaging facility' do
        subject { facet_fields["imaging_facility"] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Imaging Facility")
          expect(subject.limit).to eq(10)
        end
      end

      describe 'publication status' do
        subject { facet_fields["publication_status"]}
        it 'has the correct attributes' do
          expect(subject.label).to eq("Publication Status")
          expect(subject.limit).to eq(10)
        end
      end

      describe 'rights statement' do
        subject { facet_fields["rights_statement"]}
        it 'has the correct attributes' do
          expect(subject.label).to eq("Rights Statement")
          expect(subject.limit).to eq(10)
        end
      end

      describe 'license' do
        subject { facet_fields["license"]}
        it 'has the correct attributes' do
          expect(subject.label).to eq("CC License")
          expect(subject.limit).to eq(10)
        end
      end

      describe 'taxonomy_name' do
        subject { facet_fields["taxonomy_name"]}
        it 'has the correct attributes' do
          expect(subject.label).to eq("Taxonomy (Name)")
          expect(subject.limit).to eq(10)
        end
      end

      describe 'taxonomy_gbif' do
        subject { facet_fields["taxonomy_gbif"]}
        it 'has the correct attributes' do
          expect(subject.label).to eq("Taxonomy (GBIF)")
          expect(subject.limit).to eq(25)
        end
      end

      describe 'keyword' do
        subject { facet_fields["tag"] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Tag")
          expect(subject.limit).to eq(10)
        end
      end

      describe 'member of teams' do
        subject { facet_fields["team"] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Team")
          expect(subject.limit).to eq(10)
          expect(subject.helper_method).to eq(:collection_title_by_id)
        end
      end

      describe 'member of projects' do
        subject { facet_fields["project"] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Project")
          expect(subject.limit).to eq(10)
          expect(subject.helper_method).to eq(:collection_title_by_id)
        end
      end

      describe 'member of media lists' do
        subject { facet_fields["media_list"] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Media List")
          expect(subject.limit).to eq(10)
          expect(subject.helper_method).to eq(:collection_title_by_id)
        end
      end

      describe 'member of seq. section lists' do
        subject { facet_fields["seq_section_list"] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Seq. Section List")
          expect(subject.limit).to eq(10)
          expect(subject.helper_method).to eq(:collection_title_by_id)
        end
      end

      describe 'user_with_ownership_name' do
        subject { facet_fields["owner"] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Data Manager")
          expect(subject.limit).to eq(10)
        end
      end

      describe 'depositor_name' do
        subject { facet_fields["depositor"] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Data Uploader")
          expect(subject.limit).to eq(10)
        end
      end

      describe 'data sponsor' do
        subject { facet_fields["sponsor"] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Data Sponsor")
          expect(subject.limit).to eq(10)
        end
      end
    end

    describe 'index fields' do
      let(:index_fields) { config.index_fields }

      describe 'title' do
        subject { index_fields['title_tesim'] }

        it 'has the correct attributes' do
          expect(subject.label).to eq('Title')
          expect(subject.field).to eq('title_tesim')
        end
      end

      describe 'physical object id' do
        subject { index_fields['physical_object_id_tesim'] }

        it 'has the correct attributes' do
          expect(subject.label).to eq('Object')
          expect(subject.helper_method).to eq(:link_to_object)
          expect(subject.field).to eq('physical_object_id_tesim')
        end
      end

      describe 'taxonomy' do
        subject { index_fields['taxonomy_tesim'] }

        it 'has the correct attributes' do
          expect(subject.label).to eq("Taxonomy")
          expect(subject.field).to eq('taxonomy_tesim')
        end
      end

      describe 'part' do
        subject { index_fields['part_tesim'] }

        it 'has the correct attributes' do
          expect(subject.label).to eq("Element or Part")
          expect(subject.field).to eq('part_tesim')
        end
      end

      describe 'modality' do
        subject { index_fields['human_readable_modality_tesim'] }

        it 'has the correct attributes' do
          expect(subject.label).to eq('Modality')
          expect(subject.field).to eq('human_readable_modality_tesim')
        end
      end

      describe 'data manager' do
        subject { index_fields['user_with_ownership_ssi'] }

        it 'has the correct attributes' do
          expect(subject.label).to eq('Data Manager')
          expect(subject.field).to eq('user_with_ownership_ssi')
        end
      end

      describe 'date uploaded' do
        subject { index_fields['date_uploaded_dtsi'] }

        it 'has the correct attributes' do
          expect(subject.label).to eq('Date Uploaded')
          expect(subject.helper_method).to eq(:human_readable_date)
          expect(subject.field).to eq('date_uploaded_dtsi')
        end
      end

      describe 'rights statement' do
        subject { index_fields['rights_statement_ssim'] }

        it 'has the correct attributes' do
          expect(subject.label).to eq('Rights Statement')
          expect(subject.helper_method).to eq(:rights_statement_links)
          expect(subject.field).to eq('rights_statement_ssim')
        end
      end
    end

    describe 'show fields' do
      let(:show_fields) { config.show_fields }
      describe 'media' do
        describe 'human_readable_modality' do
          subject { show_fields["human_readable_modality_tesim"] }
          it 'has the correct attributes' do
            expect(subject.key).to eq("human_readable_modality_tesim")
            expect(subject.field).to eq("human_readable_modality_tesim")
            expect(subject.label).to eq("Human Readable Modality Tesim")
          end
        end
      end
    end

    describe 'search fields' do
      let(:search_fields) { config.search_fields }
      describe 'all_fields' do
        subject { search_fields['all_fields'] }
        it 'includes modality' do
          expect(subject.solr_parameters[:qf]).to include('human_readable_modality_tesim')
        end
      end
    end
  end

  describe '#show JSON API endpoint' do
    context 'query private media' do
      let (:media) { create(:private_media_document) }
      
      context 'without API key credentials' do
        it 'returns 404 not found' do
          get :show, params: { id: media.id }, format: :json
          expect(response.content_type).to eq('application/json')
          expect(response.code).to eq("404")
        end
      end

      context 'with invalid API key credentials' do
        it 'returns 404 not found' do
          controller.request.env['HTTP_AUTHORIZATION'] = "nonsense"
          get :show, params: { id: media.id }, format: :json
          expect(response.content_type).to eq('application/json')
          expect(response.code).to eq("404")
        end
      end

      context 'when valid API key credentials' do
        let (:user) { create(:admin) }

        it 'returns 200 found' do
          controller.request.env['HTTP_AUTHORIZATION'] = user.token
          get :show, params: { id: media.id }, format: :json
          expect(response.content_type).to eq('application/json')
          expect(response.code).to eq("200")
        expect(JSON.parse(response.body).dig("response", "media")).to be_present
        end 
      end
    end

    context 'query public media' do
      let (:media) { create(:public_media_document) }

      it 'returns 200 found' do
        get :show, params: { id: media.id }, format: :json
        expect(response.content_type).to eq('application/json')
        expect(response.code).to eq("200")
        expect(JSON.parse(response.body).dig("response", "media")).to be_present
      end
    end
  end

  describe "#show_file_metadata JSON API endpoint" do
    context 'query private media' do
      let! (:media) { create(:private_media_document) }
      let! (:file_set) { create(:file_set_document) }
      
      context 'without API key credentials' do
        it 'returns 404 not found' do
          get :show_file_metadata, params: { id: media.id }, format: :json
          expect(response.content_type).to eq('application/json')
          expect(response.code).to eq("404")
        end
      end

      context 'with invalid API key credentials' do
        it 'returns 404 not found' do
          controller.request.env['HTTP_AUTHORIZATION'] = "nonsense"
          get :show_file_metadata, params: { id: media.id }, format: :json
          expect(response.content_type).to eq('application/json')
          expect(response.code).to eq("404")
        end
      end

      context 'when valid API key credentials' do
        let (:user) { create(:admin) }

        it 'returns 200 found' do
          controller.request.env['HTTP_AUTHORIZATION'] = user.token
          get :show_file_metadata, params: { id: media.id }, format: :json
          expect(response.content_type).to eq('application/json')
          expect(response.code).to eq("200")
          expect(JSON.parse(response.body).dig("response", "file_set")).to be_present
        end 
      end
    end

    context 'query public media' do
      let! (:media) { create(:public_media_document) }
      let! (:file_set) { create(:file_set_document) }

      it 'returns 200 found' do  
        get :show_file_metadata, params: { id: media.id }, format: :json
        expect(response.content_type).to eq('application/json')
        expect(response.code).to eq("200")
        expect(JSON.parse(response.body).dig("response", "file_set")).to be_present
      end
    end
  end
end
