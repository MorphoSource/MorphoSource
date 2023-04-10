# frozen_string_literal: true
module Hyrax
  module Forms
    # rubocop:disable Metrics/ClassLength
    class CollectionForm
      include HydraEditor::Form
      include HydraEditor::Form::Permissions
      include SingleValuedForm

      # Used by the search builder
      attr_reader :scope

      delegate :id, :depositor, :permissions, :human_readable_type, :member_ids, :nestable?,
               :alternative_title, to: :model

      class_attribute :membership_service_class
      class_attribute :single_valued_fields

      # Required for search builder (FIXME)
      alias collection model

      self.model_class = ::Collection

      self.membership_service_class = Collections::CollectionMemberService

      delegate :blacklight_config, to: Hyrax::CollectionsController

      self.terms = [:alternative_title, :resource_type, :title, :creator, :contributor, :description,
                    :keyword, :license, :publisher, :date_created, :subject, :language,
                    :representative_id, :thumbnail_id, :identifier, :based_near,
                    :related_url, :visibility, :collection_type_gid, :can_submit_remote_files,
                    :allowed_remote_source]

      self.required_fields = [:title]

      self.single_valued_fields = [:title, :description]

      ProxyScope = Struct.new(:current_ability, :repository, :blacklight_config) do
        def can?(*args)
          current_ability.can?(*args)
        end
      end

      # @param model [::Collection] the collection model that backs this form
      # @param current_ability [Ability] the capabilities of the current user
      # @param repository [Blacklight::Solr::Repository] the solr repository
      def initialize(model, current_ability, repository)
        super(model)
        @scope = ProxyScope.new(current_ability, repository, blacklight_config)
      end

      def permission_template
        @permission_template ||= begin
                                   template_model = PermissionTemplate.find_or_create_by(source_id: model.id)
                                   PermissionTemplateForm.new(template_model)
                                 end
      end

      # @return [Hash] All Media in the collection, media.id is both the key and value
      def select_files
        Hash[all_files_with_access]
      end

      # Terms that appear above the accordion
      def primary_terms
        [:title, :description]
      end

      # Terms that appear within the accordion
      def secondary_terms
        [:creator, :contributor, :based_near, :related_url]
      end

      def banner_info
        @banner_info ||= begin
          # Find Banner filename
          banner_info = CollectionBrandingInfo.where(collection_id: id).where(role: "banner")
          banner_file = File.split(banner_info.first.local_path).last unless banner_info.empty?
          file_location = banner_info.first.local_path unless banner_info.empty?
          relative_path = "/" + banner_info.first.local_path.split("/")[-4..-1].join("/") unless banner_info.empty?
          { file: banner_file, full_path: file_location, relative_path: relative_path }
        end
      end

      def logo_info
        @logo_info ||= begin
          # Find Logo filename, alttext, linktext
          logos_info = CollectionBrandingInfo.where(collection_id: id).where(role: "logo")
          logos_info.map do |logo_info|
            logo_file = File.split(logo_info.local_path).last
            relative_path = "/" + logo_info.local_path.split("/")[-4..-1].join("/")
            alttext = logo_info.alt_text
            linkurl = logo_info.target_url
            { file: logo_file, full_path: logo_info.local_path, relative_path: relative_path, alttext: alttext, linkurl: linkurl }
          end
        end
      end

      # Do not display additional fields if there are no secondary terms
      # @return [Boolean] display additional fields on the form?
      def display_additional_fields?
        secondary_terms.any?
      end

      def thumbnail_title
        return unless model.thumbnail
        model.thumbnail.title.first
      end

      def list_parent_collections
        collection.member_of_collections
      end

      def list_child_collections
        collection_member_service.available_member_subcollections.documents
      end

      def available_parent_collections(scope:)
        return @available_parents if @available_parents.present?

        collection = ::Collection.find(id)
        colls = Hyrax::Collections::NestedCollectionQueryService.available_parent_collections(child: collection, scope: scope, limit_to_id: nil)
        @available_parents = colls.map do |col|
          { "id" => col.id, "title_first" => col.title.first }
        end
        @available_parents.to_json
      end

      private

      def all_files_with_access
        # if team w/ a linked organization, use collection member service
        # otherwise just get member work ids
        if self.model.team? && self.model.organization.present?
          object_ids = Morphosource::Collections::CollectionInformationService.new(scope: @scope, collection_id: id).collection_information["organization_object_ids"]
          Morphosource::Collections::CollectionMemberService.new(scope: @scope, collection: self.model, params:{}).all_member_media(object_ids).response['docs'].map{ |doc| [doc['id'], doc['id']] }
        else
          member_presenters(member_work_ids).map { |m| [m.id, m.id] }
        end
      end

      # Override this method if you have a different way of getting the member's ids
      def member_work_ids
        response = collection_member_service.available_member_work_ids.response
        response.fetch('docs').map { |doc| doc['id'] }
      end

      def collection_member_service
        @collection_member_service ||= membership_service_class.new(scope: scope, collection: collection, params: blacklight_config.default_solr_params)
      end

      def member_presenters(member_ids)
        PresenterFactory.build_for(ids: member_ids,
                                   presenter_class: WorkShowPresenter,
                                   presenter_args: [nil])
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
