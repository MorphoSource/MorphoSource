module Morphosource
  module Collections
    class CollectionSetInformationService
      # Returns derived information about collection (counts, media/category, etc.) with fast solr searches
    
      attr_reader :solr, :collection_id, :collection, :is_org_team, 
        :collection_organization_id, :team_org_po_ids, :n_media_team_organization,
        :facet_results, :media_count, :physical_object_ids, :bso_ids, :cho_ids,
        :n_idigbio, :collection_project_map, :organizations, :info, :subcollection_ids

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

        @team_org_po_ids = []
        @n_media_team_organization = 0
        @facet_results = {}
        @media_count = 0
        @physical_object_ids = []
        @bso_ids = []
        @cho_ids = []
        @n_idigbio = 0
        @collection_project_map = {}
        @organizations = []

        @collections.each do |collection_doc|

          @collection_id = collection_doc.id
          @collection = Collection.find(@collection_id)
          @is_org_team = @collection.team?
 #         if is_org_team && Collection.find(collection_id).organization.present?
 #           @collection_organization_id = Collection.find(collection_id).organization.id
 #           @team_org_po_ids += organization_po_ids
 #           @n_media_team_organization += team_org_origin_count if is_org_team
 #         end
          this_facet_results, this_media_count = media_facet_query
          @facet_results = @facet_results.merge(this_facet_results)
          @media_count += this_media_count
          @physical_object_ids += this_facet_results['physical_object_id_tesim'].keys.map(&:upcase)
          @bso_ids += po_ids_by_model(physical_object_ids, BiologicalSpecimen)          
          @cho_ids += po_ids_by_model(physical_object_ids, CulturalHeritageObject) 
          @n_idigbio += bso_idigbio_count

          @collection_project_map.merge(collection_id_to_project_title_map)

          @organizations += organization_docs

        end

      end

      def collection_information
        @info = { 
          'counts' => {
            'media' => media_count,
            'po' => physical_object_ids.length,
            'bso' => bso_ids.length,
            'cho' => cho_ids.length
          },
          'collection_object_ids' => physical_object_ids
        }

        info['media_groups'] =  { 'organization' => {} }.merge(facet_media_groups) if media_count.present?
        info['bso_groups'] = { 'organization' => {} }.merge(bso_source_groups) if bso_ids.present?
        info['cho_groups'] = { 'organization' => {} } if cho_ids.present?

#        organization_groups
#
#        if is_org_team && collection_organization_id.present?
#          info['media_groups']['origin'] = {
#            'team_organization' => n_media_team_organization,
#            'team_collection' => media_count - n_media_team_organization
#          }
#
#          if bso_ids.present?
#            team_bso_ids = team_org_po_ids.select { |x| bso_ids.include? x }
#            info['bso_groups']['origin'] = {
#              'team_organization' => team_bso_ids.length,
#              'team_collection' => bso_ids.length - team_bso_ids.length
#            }
#          end
#
#          if cho_ids.present?
#            team_cho_ids = team_org_po_ids.select { |x| cho_ids.include? x }
#            info['cho_groups']['origin'] = {
#              'team_organization' => team_cho_ids.length,
#              'team_collection' => cho_ids.length - team_cho_ids.length
#            }
#          end
#
#          if team_org_po_ids.present?
#            info['organization_object_ids'] = team_org_po_ids
#          end
#        end
#
        info     
      end

      def solrize_filter_params(params = {})
        params.map { |k, v| solrize_param(k, v) }.compact
      end

      def subcollection_ids
        @subcollection_ids ||= get_subcollection_ids
      end

      private

        ### Solr collection queries ###

        # Team-specific #

        def organization_po_ids
          solr.get_docs('id:'+collection_organization_id, { rows: 1 })&.first[solrize('member_ids', :symbol)]
        end

        def team_org_origin_count
          query = nil
          params = {
            fq: [
              assemble_po_id_and_not_collection_query(team_org_po_ids, collection_id),
              "#{solrize('has_model', :symbol)}:Media"
            ]
          }

          solr.get(query, params)
          solr.count
        end

        def get_subcollection_ids
          query = nil
          params = {
            fq: [
              "#{solrize('nesting_collection__parent_ids', :symbol)}:#{collection_id}",
              "#{solrize('has_model', :symbol)}:Collection"
            ]
          }

          solr.get_docs(query, params).map { |d| d['id'] }
        end

        # Other solr queries #

        def media_facet_query
          facet_fields = [
            solrize('media_type', :stored_searchable),
            solrize('fileset_accessibility', :stored_searchable),
            solrize('physical_object_id', :stored_searchable),
            solrize('member_of_collection_ids', :symbol)
          ]

          params = { 
            rows: 0,
            fq: [
              "#{solrize('has_model', :symbol)}:Media",
            ]
          }

          # Core query
          if is_org_team && collection_organization_id
            core_query = assemble_po_id_or_collection_query(
              team_org_po_ids, 
              Array(collection_id) + subcollection_ids
            )
          elsif collection.collection_type.nestable?
            core_query = assemble_or_query(
              solrize('member_of_collection_ids', :symbol),
              Array(collection_id) + subcollection_ids
            )
          else
            core_query = "#{solrize('member_of_collection_ids', :symbol)}:#{collection_id}"
          end

          params[:fq] << core_query += assemble_user_media_query
byebug
          solr.get_facet_fields(nil, facet_fields, params)

          return solr.facet_fields(facet_fields), solr.count
        end


        def assemble_user_media_query
          # add media by depositor and creator (not thru collections)
          role_clauses = [
            ActiveFedora::SolrQueryBuilder.construct_query_for_rel(depositor: @user.user_key),
            ActiveFedora::SolrQueryBuilder.construct_query_for_rel(creator: @user.user_key)
          ]
          joined_clauses = " OR (#{role_clauses.join(' OR ')})"
          return joined_clauses
        end

        def collection_id_to_project_title_map
          return {} if !facet_results[solrize('member_of_collection_ids', :symbol)].present?

          collection_ids = facet_results[solrize('member_of_collection_ids', :symbol)].keys
          solr.get_docs(query = nil, params = { fq: assemble_or_query('id', collection_ids)} ).
            select { |d| is_project? d['collection_type_gid_ssim']&.first }.
            map { |d| [ d['id'], d[ solrize('title', :stored_searchable) ]&.first ] }.
            to_h
        end

        def is_project?(collection_type)
          collection_type.split('/').last == '2'
        end

        def bso_idigbio_count
          return 0 if !bso_ids.present?

          params = {
            rows: 0,
            fq: [
              assemble_or_query('id', bso_ids.map { |id| prepare_value(id) } ),
              "#{solrize('idigbio_uuid', :stored_searchable)}:*"
            ] 
          }

          solr.get(nil, params)
          solr.count
        end

        def organization_docs(organization_title = '')
          return [] if !physical_object_ids.present?

          params = { 
            fl: ['id', solrize('title', :stored_searchable), solrize('member_ids', :symbol)].join(','),
            fq: [
              solrize('has_model', :symbol) + ':Organization', 
              assemble_or_query(solrize('member_ids', :symbol), physical_object_ids.map { |id| id.upcase } )
            ]
          }
          params[:fq] += ["#{solrize('title', :stored_searchable)}:#{prepare_value(organization_title)}"] if organization_title.present?

          solr.get_docs(nil, params)
        end

        def po_ids_by_model(po_ids, model)
          return [] if !po_ids.present?

          params = {
            fl: 'id',
            fq: [
              assemble_or_query('id', po_ids),
              "#{solrize('has_model', :symbol)}:#{model}"
            ]
          }

          solr.get_docs(nil, params).map(&:values).flatten
        end

        ### Collection information parsing ###

        # Convert solr facet results to media groups
        def facet_media_groups
          facet_results.map do |key, value|
            clean_key = desolrize(key)
            case clean_key
            when 'media_type'
              [ clean_key, value.transform_keys { |k| map_media_type(k) } ]
            when 'member_of_collection_ids'
              [
                'project',
                value.
                  map { |sub_k, sub_v| [collection_project_map[sub_k], sub_v] if collection_project_map.include? sub_k }.
                  compact.
                  to_h
              ]
            when 'physical_object_id'
              nil
            else
              [ clean_key, value ]
            end
          end.compact.to_h
        end

        def map_media_type(t)
          case t
            when 'ctimagesery' then 'CTImageSeries'
            when 'photogrammetryimagesery' then 'PhotogrammetryImageSeries'
            else t.titleize
          end
        end

        def bso_source_groups
          if n_idigbio.present?
            { 'source' => { 
              'idigbio' => n_idigbio, 
              'user' => physical_object_ids.length - n_idigbio
            } }
          else 
            {}
          end
        end

        def organization_groups
          po_media_counts = facet_results['physical_object_id_tesim'].transform_keys(&:upcase)
          
          # Todo: This may be not as efficient as is needed. Should index parents on children.
          organizations.map do |o|
            objs = o['member_ids_ssim'].select { |x| physical_object_ids.include? x }

            if objs.present?
              info['media_groups']['organization'][o['title_tesim']&.first] = 
                objs.reduce(0) { |sum, n| sum + po_media_counts[n] } if po_media_counts.present?

              info['bso_groups']['organization'][o['title_tesim']&.first] = 
                objs.select { |x| bso_ids.include? x }.length if bso_ids.present?

              info['cho_groups']['organization'][o['title_tesim']&.first] = 
                objs.select { |x| cho_ids.include? x }.length if cho_ids.present?
            end
          end
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
          when 'm_team_project'
            project_id = Collection.where(title: value)&.first&.id
            "#{solrize('member_of_collection_ids', :symbol)}:#{project_id}" if project_id.present?
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

        def po_ids_by_collection_organization(title)
          return [] if !title.present?

          organizations = organization_docs(title)
          filtered_org_po_ids = organizations.
            map { |o| o[solrize('member_ids', :symbol)] }.
            flatten.uniq.map(&:upcase)

          physical_object_ids.select { |po_id| filtered_org_po_ids.include? po_id }
        end

        ### Solr utility methods ###

        def solr_service
          Morphosource::SolrService
        end

        def solrize(name, type)
          Solrizer.solr_name(name, type)
        end

        def desolrize(name)
          name[0...name.rindex('_')]
        end

        def assemble_po_id_or_collection_query(ids, collection_ids)
          return "" if !ids.present? || !collection_ids.present? 
          "(#{assemble_or_query(solrize('physical_object_id', :stored_searchable), ids)}) OR (#{assemble_or_query(solrize('member_of_collection_ids', :symbol), Array(collection_ids))})"
        end

        def assemble_po_id_and_not_collection_query(ids, collection_id)
          return "" if !ids.present? || !collection_id.present? 
          "(#{assemble_or_query(solrize('physical_object_id', :stored_searchable), ids)}) AND NOT (#{solrize('member_of_collection_ids', :symbol)}:#{collection_id})"
        end

        def assemble_or_query(field, values)
          return "" if !field.present? || !values.present?
          field + ':(' + values.join(' OR ').upcase + ')'
        end

        def assemble_query
          query_clauses = [ model_clause ] + param_clauses
          query_clauses.join(' AND ')
        end

        def model_clause
          "#{Solrizer.solr_name('has_model', :symbol)}:Taxonomy"
        end

        def param_clauses
          clauses = []
          params.each do |k,v|
            term_type = ( k == 'member_ids' ? :symbol : :stored_searchable )
            clauses << "#{Solrizer.solr_name(k, term_type)}:#{prepare_value(v)}"
          end
          clauses
        end

        def prepare_value(v)
          if v.to_s.include? " "
            "\"#{v}\""
          else
            v
          end
        end

        def search_solr(qry)
          ActiveFedora::SolrService.query(qry, rows: 999999, sort: "#{SORTABLE_TITLE_FIELD} ASC")
        end
    end
  end
end