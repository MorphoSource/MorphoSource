module Morphosource
  module Collections
    class CollectionSetInformationService
      include CollectionInformationHelper
      include SolrHelper
      # Returns derived information about collection (counts, media/category, etc.) with fast solr searches
    
      attr_reader :solr, :collection_id, :collection_ids, :collection, :is_org_team, 
        :collection_organization_id, :team_org_po_ids, :n_media_team_organization,
        :facet_results, :media_count, :physical_object_ids, :bso_ids, :cho_ids,
        :n_idigbio, :collection_project_map, :collection_team_map, :po_counts_by_org, 
        :organizations, :info, :subcollection_ids,
        :manager_media_count, :editor_media_count, :depositor_media_count, 
        :downloader_media_count, :viewer_media_count,
        :manager_po_count, :editor_po_count, :depositor_po_count, 
        :downloader_po_count, :viewer_po_count

      SORTABLE_TITLE_FIELD = Solrizer.solr_name('title', :stored_sortable)

      def self.call(user, collections)
        new(user, collections).call
      end

      def self.collection_organization_object_ids(collection_id)

      end

      def initialize(user, collections)
        @solr = solr_service.new
        @user = user
        @collections = collections
        query_solr_collection_info
      end

      def call
        collection_information
      end

      def query_solr_collection_info

        @facet_results, @media_count, 
        @manager_media_count, @editor_media_count, @depositor_media_count, @downloader_media_count, @viewer_media_count, 
          @manager_po_count, @editor_po_count, @depositor_po_count, @downloader_po_count, @viewer_po_count = media_facet_query_for_collections
        @manager_media_count += user_managed_media_count

        @physical_object_ids = facet_results['physical_object_id_tesim'].keys.map(&:upcase)
        @bso_ids = po_ids_by_model(physical_object_ids, BiologicalSpecimen)          
        @cho_ids = po_ids_by_model(physical_object_ids, CulturalHeritageObject) 
        @n_idigbio = bso_idigbio_count

        @collection_project_map, @collection_team_map = collection_id_to_collection_title_map
        
        @po_counts_by_org = physical_object_counts_by_organization
        @organizations = organization_docs
      end

      def collection_information
        @info = { 
          'counts' => {
            'media' => media_count,
            'po' => physical_object_ids.length,
            'bso' => bso_ids.length,
            'cho' => cho_ids.length
          },
          'membership_counts' => {},
          'collection_object_ids' => physical_object_ids
        }
        
        info['membership_counts']["Manager"] = { "media_count" => manager_media_count, "po_count" => manager_po_count } if manager_media_count > 0
        info['membership_counts']["Editor"] = { "media_count" => editor_media_count, "po_count" => editor_po_count } if editor_media_count > 0
        info['membership_counts']["Depositor"] = { "media_count" => depositor_media_count, "po_count" => depositor_po_count } if depositor_media_count > 0
        info['membership_counts']["Downloader"] = { "media_count" => downloader_media_count, "po_count" => downloader_po_count } if downloader_media_count > 0
        info['membership_counts']["Viewer"] = { "media_count" => viewer_media_count, "po_count" => viewer_po_count } if viewer_media_count > 0

        info['media_groups'] =  { 'organization' => {} }.merge(facet_media_groups) if media_count.present?
        info['bso_groups'] = { 'organization' => {} }.merge(bso_source_groups) if bso_ids.present?
        info['cho_groups'] = { 'organization' => {} } if cho_ids.present?

        info_po_media_counts_by_organization

        if is_org_team && collection_organization_id.present?
          info['media_groups']['origin'] = {
            'team_organization' => n_media_team_organization,
            'team_collection' => media_count - n_media_team_organization
          }

          if bso_ids.present?
            team_bso_ids = team_org_po_ids.select { |x| bso_ids.include? x }
            info['bso_groups']['origin'] = {
              'team_organization' => team_bso_ids.length,
              'team_collection' => bso_ids.length - team_bso_ids.length
            }
          end

          if cho_ids.present?
            team_cho_ids = team_org_po_ids.select { |x| cho_ids.include? x }
            info['cho_groups']['origin'] = {
              'team_organization' => team_cho_ids.length,
              'team_collection' => cho_ids.length - team_cho_ids.length
            }
          end

          if team_org_po_ids.present?
            info['organization_object_ids'] = team_org_po_ids
          end
        end

        info     
      end

      def solrize_filter_params(params = {})
        params.map { |k, v| solrize_param(k, v) }.compact
      end

      def subcollection_ids(collection_ids)
        @subcollection_ids ||= get_subcollection_ids(collection_ids)
      end

      private

        ### Solr collection queries ###

        def media_and_po_count(collection_id)
          query = nil
          params = {
            fl: [solrize('physical_object_id', :stored_searchable)],
            fq: [
              "#{solrize('member_of_collection_ids', :symbol)}:#{collection_id}",
              "#{solrize('has_model', :symbol)}:Media"
            ]
          }
          solr.get(query, params)
          # also get the PO counts 
          po_count = 0
          if solr.docs.present?
            solr.docs.each do |doc|
              po_list = doc[solrize('physical_object_id', :stored_searchable)]
              po_count += po_list.length if po_list.present?
            end
          end
          return solr.count, po_count
        end

        def user_managed_media_count
          params = {
            rows: 0,
            fq: [
              assemble_user_media_query,
              "#{solrize('has_model', :symbol)}:Media"
            ]
          }
          solr.get(nil, params)
          solr.count
        end

        # Team-specific #

        def media_facet_query_for_collections
          facet_fields = [
            solrize('media_type', :stored_searchable),
            solrize('fileset_accessibility', :stored_searchable),
            solrize('physical_object_id', :stored_searchable),
            solrize('media_organization_id', :symbol),
            solrize('member_of_collection_ids', :symbol)
          ]

          params = { 
            rows: 0,
            fq: [
              "#{solrize('has_model', :symbol)}:Media",
            ],
            "facet.limit": -1
          }

          collection_ids = []
          @team_org_po_ids = []
          @collection_organization_ids = []
          @n_media_team_organization = 0
          is_org_team_included = false
          is_nestable = false

          manager_media_count = 0
          editor_media_count = 0
          depositor_media_count = 0
          viewer_media_count = 0
          downloader_media_count = 0
          manager_po_count = 0
          editor_po_count = 0
          depositor_po_count = 0
          viewer_po_count = 0
          downloader_po_count = 0

          @collections.each do |collection_doc|

            @collection_id = collection_doc.id
            @collection = Collection.find(@collection_id)
            collection_ids << @collection_id
            @is_org_team = collection.team?

            if is_org_team && collection.organization.present?
              @collection_organization_id = collection.organization.id
              @collection_organization_ids << collection.organization.id
              @team_org_po_ids << organization_po_ids if organization_po_ids.present?
              @n_media_team_organization += team_org_origin_count if is_org_team
            end

            if is_org_team && collection_organization_id
              is_org_team_included = true
            elsif collection.collection_type.nestable?
              is_nestable = true
            end

            this_media_count, this_po_count = media_and_po_count(collection_id)
            if collection.membership_of(@user).include?('Manager')
              manager_media_count += this_media_count
              manager_po_count += this_po_count
            elsif collection.membership_of(@user).include?('Editor')
              editor_media_count += this_media_count
              editor_po_count += this_po_count
            elsif collection.membership_of(@user).include?('Depositor')
              depositor_media_count += this_media_count
              depositor_po_count += this_po_count
            elsif collection.membership_of(@user).include?('Downloader')
              downloader_media_count += this_media_count
              downloader_po_count += this_po_count
            elsif collection.membership_of(@user).include?('Viewer')
              viewer_media_count += this_media_count
              viewer_po_count += this_po_count
            end

          end

          if is_org_team_included
            org_team_query = assemble_po_id_or_collection_query(team_org_po_ids.flatten, subcollection_ids(collection_ids))
          end

          if is_nestable
            nestable_query = assemble_or_query(
              solrize('member_of_collection_ids', :symbol),
              subcollection_ids(collection_ids)
            )
          end

          main_query = assemble_or_query(
            solrize('member_of_collection_ids', :symbol),
            collection_ids
          )

          query_clauses = [
            main_query,
            org_team_query,
            nestable_query,
            assemble_user_media_query
          ] - ["", nil]
          combined_query = "(#{query_clauses.join(' OR ')})"
          params[:fq] << combined_query
          solr.get_facet_fields(nil, facet_fields, params)

          return solr.facet_fields(facet_fields), solr.count, 
            manager_media_count, editor_media_count, depositor_media_count, downloader_media_count, viewer_media_count, 
            manager_po_count, editor_po_count, depositor_po_count, downloader_po_count, viewer_po_count
        end

        def assemble_user_media_query
          # add media by depositor and creator (not thru collections)
          role_clauses = [
            ActiveFedora::SolrQueryBuilder.construct_query_for_rel(depositor: @user.user_key),
            ActiveFedora::SolrQueryBuilder.construct_query_for_rel(creator: @user.user_key)
          ]
          joined_clauses = "(#{role_clauses.join(' OR ')})"
          return joined_clauses
        end

        def collection_id_to_collection_title_map
          return {} if !facet_results[solrize('member_of_collection_ids', :symbol)].present?
          projects = {}
          teams = {}
          collection_ids = facet_results[solrize('member_of_collection_ids', :symbol)].keys
          docs = solr.get_docs(query = nil, params = { fq: assemble_or_query('id', collection_ids)} )
          docs.each do |d|
            if is_project? d['collection_type_gid_ssim']&.first 
              projects = projects.merge( { d['id'] => d[ solrize('title', :stored_searchable) ]&.first } )
            else
              teams = teams.merge( { d['id'] => d[ solrize('title', :stored_searchable) ]&.first } )
            end
          end
          return projects, teams
        end

        ### Collection information parsing ###

        # Convert solr facet results to media groups
        def facet_media_groups
          fields = []
          facet_results.map do |key, value|
            clean_key = desolrize(key)
            case clean_key
            when 'media_type'
              fields << [ clean_key, value.transform_keys { |k| map_media_type(k) } ]
            when 'member_of_collection_ids'
              fields << [
                'project',
                value.
                  map { |sub_k, sub_v| [collection_project_map[sub_k], sub_v] if collection_project_map.include? sub_k }.
                  compact.
                  to_h
              ]
              fields << [
                'team',
                value.
                  map { |sub_k, sub_v| [collection_team_map[sub_k], sub_v] if collection_team_map.include? sub_k }.
                  compact.
                  to_h                  
              ]
            when 'physical_object_id'
              # nil
            else
              fields << [ clean_key, value ]
            end
          end
          return fields.compact.to_h
        end

        ### Collection solrize filter params ###

        def solrize_param(name, value)
          case name
          when 'm_pub_status'
            "#{solrize('fileset_accessibility', :stored_searchable)}:#{value}"
          when 'm_organization'
            assemble_or_query(
              solrize('physical_object_id', :stored_searchable), 
              po_ids_by_collection_organization(value)
            )
          when 'm_project'
            project_id = Collection.where(title: value)&.first&.id
            "#{solrize('member_of_collection_ids', :symbol)}:#{project_id}" if project_id.present?
          when 'm_team'
            team_id = Collection.where(title: value)&.first&.id
            "#{solrize('member_of_collection_ids', :symbol)}:#{team_id}" if team_id.present?
          when 'm_origin'
            if value == 'team_collection'
              "#{solrize('member_of_collection_ids', :symbol)}:#{collection_id}"
            elsif value == 'team_organization' && Collection.find(collection_id).organization.present?
              organization_title = Collection.find(collection_id).organization.title&.first
              assemble_po_id_and_not_collection_query(
                po_ids_by_collection_organization(organization_title),
                collection_id
              )
            end
          when 'b_source'
            if value == 'idigbio'
              "#{solrize('idigbio_uuid', :stored_searchable)}:*"
            elsif value == 'user'
              "-#{solrize('idigbio_uuid', :stored_searchable)}:*"
            end
          when 'b_organization', 'c_organization'
            assemble_or_query(
              'id', 
              po_ids_by_collection_organization(value)
            )
          when 'b_origin', 'c_origin'
            if Collection.find(collection_id).organization.present?
              organization_title = Collection.find(collection_id).organization.title&.first
              organization_po_query = assemble_or_query(
                'id', 
                po_ids_by_collection_organization(organization_title)
              )

              if value == 'team_collection'
                '-' + organization_po_query
              elsif value == 'team_organization'
                organization_po_query
              end
            end
          else
            "#{solrize(name.split('_', 2).last, :stored_searchable)}:#{value}"
          end
        end
    end
  end
end