require 'rails_helper'

RSpec.describe AllCatalogController, :type => :controller do

  describe 'Blacklight Configuration' do
    let(:config) { described_class.new.blacklight_config }
    describe 'search_builder_class' do
      it 'is the hyrax catalog search builder' do
        expect(config.search_builder_class).to eq(Morphosource::CatalogSearchBuilder)
      end
    end
    describe 'facet fields' do
      let(:facet_fields) { config.facet_fields }

      it 'has 15 facet fields' do
        expect(facet_fields.count).to eq(15)
      end

      describe 'human readable type' do
        subject { facet_fields['human_readable_type_ssim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Work Type")
          expect(subject.limit).to eq(5)
        end
      end

      describe 'human readable media type' do
        subject { facet_fields['human_readable_media_type_ssim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Media Type")
          expect(subject.limit).to eq(5)
        end
      end

      describe 'media modality' do
        subject { facet_fields['modality_ssim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Media Modality")
          expect(subject.limit).to eq(6)
        end
      end

      describe 'media physical object type' do
        subject { facet_fields['media_physical_object_type_ssim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Media Object Type")
          expect(subject.limit).to eq(5)
        end
      end

      describe 'media organization' do
        subject { facet_fields['media_organization_ssim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Media Organization")
          expect(subject.limit).to eq(5)
        end
      end

      describe 'media keyword' do
        subject { facet_fields['keyword_ssim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Media Tag")
          expect(subject.limit).to eq(5)
        end
      end

      describe 'media taxonomy' do
        subject { facet_fields['taxonomy_ssim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Media Taxonomy")
          expect(subject.limit).to eq(5)
        end
      end

      describe 'object creator' do
        subject { facet_fields['creator_ssim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Object Creator")
          expect(subject.limit).to eq(5)
        end
      end

      describe 'object organization' do
        subject { facet_fields['organization_ssim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Object Organization")
          expect(subject.limit).to eq(5)
        end
      end

      describe 'media collections' do
        subject { facet_fields['media_collections_sim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Object Media Team / Project")
          expect(subject.limit).to eq(5)
        end
      end

      describe 'media keyword' do
        subject { facet_fields['media_keyword_sim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Object Media Tag")
          expect(subject.limit).to eq(5)
        end
      end

      describe 'organization type' do
        subject { facet_fields['organization_type_sim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Organization Type")
          expect(subject.limit).to eq(5)
        end
      end

      describe 'linked organization' do
        subject { facet_fields['linked_organization_sim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Team Organization")
          expect(subject.limit).to eq(5)
        end
      end
    end
  end


  describe 'GET #index' do
    subject { get :index }
    context 'user is not logged in' do
      it 'redirects to catalog/media' do
        expect(subject).to redirect_to(media_search_path)
      end
    end
    context 'user is logged in' do
      let(:user) { User.create(email: 'email@email.com', password: 'password') }

      before do
        sign_in user
      end
      context 'user is not an admin' do
        it 'redirects to catalog/media' do
          expect(subject).to redirect_to(media_search_path)
        end
      end
      context 'user is an admin' do
        before do
          admin_role = Role.create(name: 'admin')
          admin_role.users << user
          admin_role.save
        end
        it 'does not redirect to catalog/media' do
          expect(subject).not_to redirect_to(media_search_path)
        end
        it 'renders the morphosource_1_column layout' do
          subject
          expect(response).to render_template("layouts/hyrax/morphosource_1_column")
        end
      end
    end
  end
end
