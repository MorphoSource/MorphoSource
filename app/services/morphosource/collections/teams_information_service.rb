module Morphosource
  module Collections
    class TeamsInformationService  
      include SolrHelper

      attr_reader :solr, :collection_list_type_id, :collection_ids, :info, :facet_results, :organizations, 
        :collection_count_for_manager, :collection_count_for_editor, :collection_count_for_depositor,
        :collection_count_for_viewer, :collection_count_for_downloader, :ids_by_membership

      SORTABLE_TITLE_FIELD = Solrizer.solr_name('title', :stored_sortable)

      def self.call(user, collection_list_type_id, page = "my")
        new(user, collection_list_type_id, browse).call
      end

      def initialize(user, collection_list_type_id, page = "my")
        # the service is shared by dashboard my teams/projects page and browse teams/projects
        @solr = solr_service.new
        @user = user
        @collection_list_type_id = collection_list_type_id
        if page == "my"
          @collection_count_for_manager = 0
          @collection_count_for_editor = 0
          @collection_count_for_depositor = 0
          @collection_count_for_viewer = 0
          @collection_count_for_downloader = 0
          @ids_by_membership = { 'Manager' => [], 'Editor' => [], 'Depositor' => [], 'Viewer' => [], 'Downloader' => [], 'any' => [] }
          membership_info(all_collection_ids)
          query_solr_collection_info
        else
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
        @info = { 
          'counts' => {}
        }
        info['counts']['Manager'] = @collection_count_for_manager if @collection_count_for_manager > 0
        info['counts']['Editor'] = @collection_count_for_editor if @collection_count_for_editor > 0
        info['counts']['Depositor'] = @collection_count_for_depositor if @collection_count_for_depositor > 0
        info['counts']['Downloader'] = @collection_count_for_downloader if @collection_count_for_downloader > 0
        info['counts']['Viewer'] = @collection_count_for_viewer if @collection_count_for_viewer > 0

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
            ]
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

        def membership_info(all_collection_ids)
          all_collection_ids.each do |id|
            begin
              membership = Collection.find(id).membership_of(@user)
            rescue Exception => e  
              # some collections end up with an exception below.
              # undefined method `users' for nil:NilClass
              # todo: remove the exception catching later if not needed
              membership = []
              Rails.logger.debug("Error in membership_info, #{e}, collection id: #{id}")
            end
            if membership.include?('Manager')
              @collection_count_for_manager += 1
              @ids_by_membership['Manager'] << id
              @ids_by_membership['any'] << id
            elsif membership.include?('Editor')
              @collection_count_for_editor += 1
              @ids_by_membership['Editor'] << id
              @ids_by_membership['any'] << id
            elsif membership.include?('Depositor')
              @collection_count_for_depositor += 1
              @ids_by_membership['Depositor'] << id
              @ids_by_membership['any'] << id
            elsif membership.include?('Viewer')
              @collection_count_for_viewer += 1
              @ids_by_membership['Viewer'] << id
              @ids_by_membership['any'] << id
            elsif membership.include?('Downloader')
              @collection_count_for_downloader += 1
              @ids_by_membership['Downloader'] << id
              @ids_by_membership['any'] << id
            else
            end          
          end
          @collection_ids = @ids_by_membership['any']
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
            assemble_or_query('id', ids_by_membership[value])
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