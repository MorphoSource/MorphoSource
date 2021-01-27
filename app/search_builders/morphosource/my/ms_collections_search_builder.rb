# Added to allow for the My controller to show only things I have edit access to
class Morphosource::My::MsCollectionsSearchBuilder < ::SearchBuilder
  #include Hyrax::My::SearchBuilderBehavior
  #include Hyrax::FilterByType

  #self.default_processor_chain += [:show_all_collections]

  def initialize(scope:)
    super(scope)
  end

  #def show_all_collections(solr_parameters)
  #  solr_parameters[:fq] ||= []
  #  solr_parameters[:fq] += [ActiveFedora::SolrQueryBuilder.construct_query_for_rel(has_model: 'Collection')]
  #  solr_parameters[:fq]
  #end


  # This overrides the models in FilterByType
  # @return [Array<Class>] a list of classes to include
  def models
    #[::AdminSet, ::Collection]
    [::Collection]
  end


  # Overrides Hydra::AccessControlsEnforcement
  def discovery_permissions
    @discovery_permissions = extract_discovery_permissions(@access)
  end

  def with_access(access)
    @access = access
    super(access)
  end

  private

    ACCESS_LEVELS_FOR_LEVEL = ActiveSupport::HashWithIndifferentAccess.new(
      edit: ["edit"],
      deposit: ["deposit"],
      read: ["edit", "read"],
      view: [Hyrax::PermissionTemplateAccess::MANAGE,
      Hyrax::PermissionTemplateAccess::EDIT_WORKS,
      Hyrax::PermissionTemplateAccess::DEPOSIT,
      Hyrax::PermissionTemplateAccess::DOWNLOAD_WORKS,
      Hyrax::PermissionTemplateAccess::VIEW]
    ).freeze

    def extract_discovery_permissions(access)
      access = :read if access.blank?
      ACCESS_LEVELS_FOR_LEVEL.fetch(access)
    end

end
