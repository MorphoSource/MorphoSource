module Morphosource
  module Collections
    class TeamsInformationService  
      include SolrHelper

      attr_reader :solr, :collection_list_type_id, :collection_ids, :info, :facet_results, :organizations, 
        :collection_count_for_manager, :collection_count_for_editor, :collection_count_for_depositor,
        :collection_count_for_viewer, :collection_count_for_downloader, :ids_by_membership

      SORTABLE_TITLE_FIELD = ActiveFedora.index_field_mapper.solr_name('title', :stored_sortable)

      def self.call(user, collection_list_type_id, page = "my")
        new(user, collection_list_type_id, browse).call
      end

      def initialize(user, collection_list_type_id, page = "my", target_collection_ids)
        # the service is shared by dashboard my teams/projects page and browse teams/projects
        @solr = solr_service.new
        @user = user
        @collection_list_type_id = collection_list_type_id
        if page == "my"
          @collection_ids = target_collection_ids
          query_solr_collection_info
        else # browse page
          @collection_ids = all_collection_ids
        end
        if is_team?
          @organizations = organization_docs
        end
      end

      #def call
      #  collection_information
      #end

      def query_solr_collection_info
        @facet_results = facet_query_for_collections
      end

      def collection_information
        @info = {}
        info['collection_groups'] = { 'organization' => {} }.merge(facet_collection_groups)
        organization_groups

        info     
      end

      # for browse pages
      def collection_information_for_browse
        @info = { 
          'counts_for_team_type' => {}
        }
        total_organizations = total_organization_teams(@collection_ids)
        info['counts_for_team_type']['org_teams'] = total_organizations
        info['counts_for_team_type']['user_teams'] = @collection_ids.length - total_organizations
        info     
      end

      def solrize_filter_params(params = {})
        params.map { |k, v| solrize_param(k, v) }.compact
      end

      def default_membership_params
        assemble_or_query('id', ids_by_membership['any'])
      end

      def browse_collection_params
        "#{solrize('visibility', :stored_sortable)}:open"
      end

      private

        ### Solr collection queries ###

        def all_collection_ids
          params = { 
            fl: ['id'],
            fq: [
              "#{solrize('has_model', :symbol)}:Collection",
              "(#{solrize('collection_type_gid', :symbol)}:\"gid://morpho-source-sf/hyrax-collectiontype/#{@collection_list_type_id}\")"
            ]
          }
          solr.get(nil, params)        
          if solr.docs.present? 
            coll_ids = solr.docs.map{|x| x['id']}
          else
            coll_ids = []
          end
          coll_ids          
        end

        def facet_query_for_collections
          return {} unless collection_ids.present?
          facet_fields = [
            solrize('visibility', :stored_sortable)
          ]
          params = { 
            #rows: 0,
            fl: ['id'],
            fq: [
              "#{solrize('has_model', :symbol)}:Collection",
              "(#{solrize('collection_type_gid', :symbol)}:\"gid://morpho-source-sf/hyrax-collectiontype/#{@collection_list_type_id}\")",
              assemble_or_query('id', collection_ids)
            ],
            "facet.limit": -1
          }
          solr.get_facet_fields(nil, facet_fields, params)
          return solr.facet_fields(facet_fields)
        end

        #def is_project?(collection_type)
        #  collection_type.split('/').last == '2'
        #end

        def is_project?
          @collection_list_type_id == 2
        end

        def is_team?
          @collection_list_type_id == 1
        end

        def organization_docs(organization_title = '')
          return [] unless collection_ids.present?

          params = { 
            fl: ['id', solrize('title', :stored_searchable), solrize('team_id', :stored_searchable)].join(','),
            fq: [
              solrize('has_model', :symbol) + ':Organization',
              assemble_or_query(solrize('team_id', :stored_searchable), collection_ids)
            ]
          }
          params[:fq] += ["#{solrize('title', :stored_searchable)}:#{prepare_value(organization_title)}"] if organization_title.present?

          return solr.get_docs(nil, params)
        end

        def organization_title_count(organization_title)
          return 0 unless collection_ids.present?

          params = { 
            rows: 0,
            fq: [
              solrize('has_model', :symbol) + ':Organization',
              assemble_or_query(solrize('team_id', :stored_searchable), collection_ids),
              "#{solrize('title', :stored_searchable)}:#{prepare_value(organization_title)}"
            ]
          }
          solr.get(nil, params)
          solr.count
        end

        def total_organization_teams(ids)
          return 0 unless ids.present?
          params = { 
            rows: 0,
            fq: [
              solrize('has_model', :symbol) + ':Organization',
              assemble_or_query(solrize('team_id', :stored_searchable), ids)
            ]
          }
          solr.get(nil, params)
          solr.count
        end

        ### Collection information parsing ###

        def facet_collection_groups
          facet_results.map do |key, value|
            clean_key = desolrize(key)
            [ clean_key, value ]
          end.compact.to_h
        end

        def organization_groups
          return nil if !organizations.present?
          organizations.map do |o|
            info['collection_groups']['organization'][o['title_tesim']&.first] = organization_title_count(o['title_tesim']&.first)
          end
        end

        ### Collection solrize filter params ###

        def solrize_param(name, value)
          case name
          when 'k_visibility'
            "#{solrize('visibility', :stored_sortable)}:#{value}"
          when 'k_organization'
            assemble_or_query('id', team_ids_by_collection_organization(value))
          when 'k_membership'
            # the target_collection_ids already contain collections from the target membership
            # therefore no need to filter here
            #assemble_or_query('id', ids_by_membership[value])
          else
            "#{solrize(name.split('_', 2).last, :stored_searchable)}:#{value}"
          end
        end

        def team_ids_by_collection_organization(title)
          return [] if !title.present?
          organizations = organization_docs(title)
          filtered_org_team_ids = organizations.
            map { |o| o[solrize('team_id', :stored_searchable)] }.
            flatten.uniq.map(&:upcase)

          filtered_org_team_ids
        end
    end
  end
end