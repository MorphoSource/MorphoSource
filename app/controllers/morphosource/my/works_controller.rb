module Morphosource
  module My
    class WorksController < Hyrax::My::WorksController
      include WorksControllerBehavior
      include Morphosource::My::WorksHelper

      class_attribute :create_work_presenter_class
      self.create_work_presenter_class = Hyrax::SelectTypeListPresenter

      with_themed_layout 'morphosource_dashboard'

      before_action :tab_variables, only: [:index]

      def index
        # The user's collections for the "add to collection" form
        @user_collections = collections_service.search_results(:deposit)
        add_breadcrumbs
        # media/object counts at top of page
        get_media_object_counts
        # managed_works_count
        @create_work_presenter = create_work_presenter_class.new(current_user)
        @user = current_user
        (@response, @document_list) = query_solr
        prepare_instance_variables_for_batch_control_display
        index_response
      end

      def index_response
        respond_to do |format|
          format.html {
            render 'morphosource/my/works/index'
          }
          format.rss  { render layout: false }
          format.atom { render layout: false }
        end
      end

      # def filter_collection_facets
      #   # puts Benchmark.measure{ filter_projects }
      #   filter_projects
      #   # puts Benchmark.measure{ filter_teams }
      #   byebug
      # end
      #
      # def filter_projects
      #   project_facet = @response.facet_fields["member_of_project_ids_ssim"]
      #   return unless project_facet
      #   # @response.facet_fields["member_of_project_ids_ssim"] = filter_collection_ids(project_facet)
      #   filter_collection_ids(project_facet)
      # end
      #
      # def filter_teams
      #   team_facet = @response.facet_fields["member_of_team_ids_ssim"]
      #   return unless team_facet
      #   @response.facet_fields["member_of_team_ids_ssim"] = filter_collection_ids(team_facet)
      # end

      # def collection_view_ids
      #   # @collection_view_ids ||= Hyrax::Collections::PermissionsService.collection_ids_for_view(ability: current_ability)
      #   @collection_view_ids ||= ActiveFedora::Base.where("has_model_ssim:Collection").accessible_by(current_ability, :read).map(&:id)
      # end

      # def filter_collection_ids(facet)
      #   facet.each_with_object([]) do |element, filtered_values|
      #     next if element.is_a? Integer
      #     next if !collection_view_ids.include? element
      #     count_index = facet.index(element) + 1
      #     filtered_values << element << facet[count_index]
      #   end
      # end

      # 0.273720   0.018014   0.291734 (  0.768750)
      # 0.000045   0.000064   0.000109 (  0.000040)
      # def filter_collection_ids(facet)
      #   viewable_ids = facet & collection_view_ids
      #   viewable_ids.each_with_object([]) do |id, filtered_values|
      #     count_index = facet.index(id) + 1
      #     filtered_values << id << facet[count_index]
      #   end
      # end

      # 0.251230   0.024182   0.275412 (  0.723394)
      # 0.000086   0.000037   0.000123 (  0.000114)

      # 0.433813   0.089838   0.523651 (  1.031961)
      # 0.000087   0.000037   0.000124 (  0.000034)
      # def filter_collection_ids(facet)
      #   puts Benchmark.measure { collection_view_ids }
      #   byebug
      #   puts Benchmark.measure { @viewable_collection_ids = facet & collection_view_ids }
      #   byebug
      #   puts Benchmark.measure { @hidden_ids = facet.select { |e| e.is_a? String } - @viewable_collection_ids }
      #   byebug
      #   # hidden_ids.each do |id|
      #   #   count_index = facet.index(id) + 1
      #   #   facet.delete_at(count_index)
      #   #   facet.delete(id)
      #   # end
      #   # facet
      # end
    end
  end
end
