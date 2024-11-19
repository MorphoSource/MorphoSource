require 'rails_helper'
RSpec.describe Morphosource::Facets::Collections do
  let!(:user)                     { User.create(email: 'user@email.com', password: 'password') }
  let!(:current_ability)          { Ability.new(user) }
  let!(:private_project)          { Collection.create(title: ['private project'], collection_type_gid: project_collection_type.to_global_id, visibility: 'restricted') }
  let!(:open_project)             { Collection.create(title: ['open project'], collection_type_gid: project_collection_type.to_global_id, visibility: 'open') }
  let(:scope)                     { double('Scope') }
  let(:solr_parameters)           { {} }

  let(:media_facet_filters)              { {
    "f.member_of_collection_ids_ssim.facet.excludeTerms"=>private_project.id,
    "f.member_of_team_ids_ssim.facet.excludeTerms"=>private_project.id,
    "f.member_of_project_ids_ssim.facet.excludeTerms"=>private_project.id} }

  let(:object_facet_filters)             { {
     "f.media_member_of_team_ids_ssim.facet.excludeTerms"=>private_project.id,
     "f.media_member_of_project_ids_ssim.facet.excludeTerms"=>private_project.id} }

  before do
    allow(scope).to receive(:current_ability).and_return(current_ability)
    allow_any_instance_of(Morphosource::Collections::SpecimensSearchBuilder).to receive(:current_ability).and_return(current_ability)
    allow_any_instance_of(Morphosource::Collections::ChosSearchBuilder).to receive(:current_ability).and_return(current_ability)
    allow_any_instance_of(Morphosource::Users::MyMediaSearchBuilder).to receive(:current_ability).and_return(current_ability)
    allow_any_instance_of(Morphosource::Users::MyObjectsSearchBuilder).to receive(:current_ability).and_return(current_ability)
  end

  # bundling all the examples together to speed up the test - unnecessary to recreate all the objects for each run.
  context 'media/objects search builders' do
    it 'filters the collection facet for access' do

      # media catalog search builder
      media_catalog = Morphosource::Catalog::MediaCatalogSearchBuilder.new(scope)
      expect(media_catalog.default_processor_chain).to include(:filter_collection_facet_for_access)
      expect(has_media_facet_filters?(media_catalog)).to be(true)

      # objects catalog search builder
      objects_catalog = Morphosource::Catalog::ObjectsCatalogSearchBuilder.new(scope)
      expect(objects_catalog.default_processor_chain).to include(:filter_collection_facet_for_access)
      expect(has_object_facet_filters?(objects_catalog)).to be(true)

      # collection media search builder
      collection_media = Morphosource::Collections::MediaSearchBuilder.new(scope: scope, collection: open_project)
      expect(collection_media.default_processor_chain).to include(:filter_collection_facet_for_access)
      expect(has_media_facet_filters?(collection_media)).to be(true)

      # collection specimens
      collection_specimens = Morphosource::Collections::SpecimensSearchBuilder.new(scope: scope, collection: open_project)
      expect(collection_specimens.default_processor_chain).to include(:filter_collection_facet_for_access)
      expect(has_object_facet_filters?(collection_specimens)).to be(true)

      # collection cultural heritage objects
      collection_objects = Morphosource::Collections::ChosSearchBuilder.new(scope: scope, collection: open_project)
      expect(collection_objects.default_processor_chain).to include(:filter_collection_facet_for_access)
      expect(has_object_facet_filters?(collection_objects)).to be(true)

      # dashboard my media
      my_media = Morphosource::Users::MyMediaSearchBuilder.new(scope: scope, collection:  open_project)
      expect(my_media.default_processor_chain).to include(:filter_collection_facet_for_access)
      expect(has_media_facet_filters?(my_media)).to be(true)

      # dashboard my objects
      my_objects = Morphosource::Users::MyObjectsSearchBuilder.new(scope: scope, collection: open_project)
      expect(my_objects.default_processor_chain).to include(:filter_collection_facet_for_access)
      expect(has_object_facet_filters?(my_objects)).to be(true)
    end
  end

  def has_media_facet_filters?(search_builder)
    solr_parameters = {}
    search_builder.filter_collection_facet_for_access(solr_parameters)
    solr_parameters == media_facet_filters
  end

  def has_object_facet_filters?(search_builder)
    solr_parameters = {}
    search_builder.filter_collection_facet_for_access(solr_parameters)
    solr_parameters == object_facet_filters
  end
end
