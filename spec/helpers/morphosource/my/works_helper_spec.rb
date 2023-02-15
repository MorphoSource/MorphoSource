require 'rails_helper'

RSpec.describe MorphosourceHelper, type: :helper do
  let(:user)            { User.create(email: 'user@email.com', password: 'password') }
  let(:collection_type) { Hyrax::CollectionType.create(title: ['collection']) }
  let(:collection)      { Collection.create(title: ['collection'], collection_type_gid: collection_type.gid) }

  let(:params) { ActionController::Parameters.new( {  } ) }

  # TODO - this method needs to be refactored, adding tests just for lists for now.
  describe 'search_action_for_dashboard' do
    before do
      allow(Collection).to receive(:find).with(collection.id).and_return(collection)
      allow(collection).to receive(:managers).and_return([])
      allow(helper).to receive(:params).and_return(params)
      helper.instance_variable_set(:@collection, collection)
      params[:controller] = controller_param
    end

    context 'controller is morphosource/collections/media_lists' do
      let(:controller_param)  { "morphosource/collections/media_lists" }
      it { expect(helper.search_action_for_dashboard).to eq(main_app.media_list_media_path(collection.id)) }
    end

    context "morphosource/collections/media_lists/sequential_section_lists" do
      let(:controller_param)  { "morphosource/collections/media_lists/sequential_section_lists" }
      it { expect(helper.search_action_for_dashboard).to eq(main_app.sequential_section_list_media_path(collection.id)) }
    end

    context "morphosource/collections/biological_specimens" do
      let(:controller_param)  { "morphosource/collections/biological_specimens" }
      context "@collection.media_list?" do
        before do
          allow(collection).to receive(:media_list?).and_return(true)
        end
        it { expect(helper.search_action_for_dashboard).to eq(main_app.media_list_specimens_path(collection.id)) }
      end
      context "@collection.sequential_section_list?" do
        before do
          allow(collection).to receive(:sequential_section_list?).and_return(true)
        end
        it { expect(helper.search_action_for_dashboard).to eq(main_app.sequential_section_list_specimens_path(collection.id)) }
      end
    end

    context "morphosource/collections/cultural_heritage_objects" do
      let(:controller_param)  { "morphosource/collections/cultural_heritage_objects" }
      context "@collection.media_list?" do
        before do
          allow(collection).to receive(:media_list?).and_return(true)
        end
        it { expect(helper.search_action_for_dashboard).to eq(main_app.media_list_chos_path(collection.id)) }
      end
      context "@collection.sequential_section_list?" do
        before do
          allow(collection).to receive(:sequential_section_list?).and_return(true)
        end
        it { expect(helper.search_action_for_dashboard).to eq(main_app.sequential_section_list_chos_path(collection.id)) }
      end
    end
  end
end