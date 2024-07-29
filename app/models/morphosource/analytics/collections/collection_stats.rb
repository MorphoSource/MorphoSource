module Morphosource
  module Analytics
    module Collections
      # Counts, views, and downloads statistics for a collection
      # Does NOT apply ability to searches

      class CollectionStats
        def initialize(collection)
          @id = collection.is_a?(String) ? collection : collection.id
        end

        # returns the ids of media associated with this collection through an object or a device
        def media_ids
          if @object_media_ids && @device_media_ids
            @media_ids ||= (@object_media_ids + @device_media_ids).uniq
          else
            @media_ids ||= Morphosource::SolrService.new.get_docs("media_organization_id_ssim:#{@id} OR media_device_facility_organization_id_ssim:#{@id}",
                                                                  fl: 'id',
                                                                  qt: 'standard',
                                                                  rows: 999_999 )
                                                                  .map { |d| d['id'] }
          end
        end

        # returns the count of media associated with this collection through an object or a device
        def media_count
          if @media_ids
            @media_count ||= @media_ids.count
          else
            @media_count ||= ActiveFedora::SolrService.count("media_organization_id_ssim:#{@id} OR media_device_facility_organization_id_ssim:#{@id}",
                                                             opts: { rows: 999_999 } )
          end
        end

        # returns media ids associated with this collection through an object
        def object_media_ids
          @object_media_ids ||= Morphosource::SolrService.new.get_docs("has_model_ssim:Media AND media_organization_id_ssim:#{@id}",
                                                                       fl: 'id', qt: 'standard', rows: 999_999 )
                                                                       .map { |d| d['id'] }
        end

        # returns the count of media associated with this collection through an object
        def object_media_count
          if @object_media_ids
            @object_media_count ||= @object_media_ids.count
          else
            @object_media_count ||= ActiveFedora::SolrService.count("has_model_ssim:Media AND media_organization_id_ssim:#{@id}", opts: { rows: 999_999 })
          end
        end

        # returns media ids associated with this collection through a device
        def device_media_ids
          @device_media_ids ||= Morphosource::SolrService.new.get_docs("has_model_ssim:Media AND media_device_facility_organization_id_ssim:#{@id}",
                                                                      fl: 'id', qt: 'standard', rows: 999_999)
                                                                      .map { |d| d['id'] }
        end

        # returns the count of media imaged by a device managed by this organization
        def device_media_count
          if @device_media_ids
            @device_media_count ||= @device_media_ids.count
          else
            @device_media_count ||= ActiveFedora::SolrService.count("has_model_ssim:Media AND media_device_facility_organization_id_ssim:#{@id}",
                                                                    opts: { rows: 999_999 } )
          end
        end

        # returns the total count of objects associated with media that:
        # represent objects managed by this organization OR
        # were imaged by a device managed by this organization
        def object_count
          if @specimen_count && @cho_count
            @object_count ||= @specimen_count + @cho_count
          else
            @object_count ||= Morphosource::SolrService.new.get_docs("media_organization_id_ssim:#{@id} OR media_device_facility_organization_id_ssim:#{@id}",
                                                                      fl: 'physical_object_id_ssim',
                                                                      qt: 'standard',
                                                                      rows: 999_999)
          end                                                         .map { |d| d['physical_object_id_ssim'] }.uniq.count
        end

        # returns the total count of specimens associated with media that:
        # represent specimens managed by this organization OR
        # were imaged by a device managed by this organization
        def specimen_count
          @specimen_count ||= Morphosource::SolrService.new.get_docs("media_organization_id_ssim:#{@id} OR media_device_facility_organization_id_ssim:#{@id}",
                                                                      fl: 'physical_object_id_ssim',
                                                                      fq: ['media_physical_object_type_ssim:("Biological Specimen")'],
                                                                      qt: 'standard',
                                                                      rows: 999_999)
                                                                      .map { |d| d['physical_object_id_ssim'] }.uniq.count
        end

        # returns the total count of cultural heritage objects associated with media that:
        # represent objects managed by this organization OR
        # were imaged by a device managed by this organization
        def cho_count
          @specimen_count ||= Morphosource::SolrService.new.get_docs("media_organization_id_ssim:#{@id} OR media_device_facility_organization_id_ssim:#{@id}",
                                                                     fl: 'physical_object_id_ssim',
                                                                     fq: ['media_physical_object_type_ssim:("Cultural Heritage Object")'],
                                                                     qt: 'standard',
                                                                     rows: 999_999)
                                                                     .map { |d| d['physical_object_id_ssim'] }.uniq.count
        end

        # returns the total count of devices managed by this organization
        def device_count
          @device_count ||= ActiveFedora::SolrService.count("has_model_ssim:Device AND organization_id_ssim:#{@id}",
                                                            opts: { fl: 'id', rows: 999_999 } )
        end

        # returns the total count of projects in this organization
        def project_count
          @project_count ||= ActiveFedora::SolrService.count("has_model_ssim:Collection AND member_of_collection_ids_ssim:#{@id}",
                                                             opts: { fl: 'id', rows: 999_999 } )
        end

        # returns a hash of media ids and their download counts
        # Ex: {"000200007"=>24, "000200012"=>10}
        def downloads
          @downloads ||= CartItem.where(work_id: media_ids)
                         .where.not(date_downloaded:nil)
                         .group(:work_id).count
        end

        # returns the total download count for all media
        def downloads_count
          @downloads_count ||= downloads.map { |view| view.last }.sum
        end

        # returns an array containing the top downloaded media id and its download count
        # Ex: ["000200007", 24]
        def top_download
          @top_download ||= downloads.max_by { |k,v| v }
        end

        # returns a hash of media ids and their download counts
        # Ex: {"000200007"=>24, "000200012"=>10}
        def object_media_downloads
          @object_media_downloads ||= downloads.dup.extract!(*object_media_ids)
        end

        # returns the total download count for all object media
        def object_media_downloads_count
          @object_media_downloads_count ||= object_media_downloads.map { |view| view.last }.sum
        end

        # returns an array containing the top downloaded object media id and its download count
        # Ex: ["000200007", 24]
        def top_object_media_download
          @top_object_media_download ||= object_media_downloads.max_by { |k,v| v }
        end

        # returns a hash of media ids and their download counts
        # Ex: {"000200007"=>24, "000200012"=>10}
        def device_media_downloads
          @device_media_downloads ||= downloads.dup.extract!(*device_media_ids)
        end

        # returns the total download count for all device media
        # Ex: 10
        def device_media_downloads_count
          @device_media_downloads_count ||= device_media_downloads.map { |view| view.last }.sum
        end

        # returns an array containing the top downloaded device media id and its download count
        # Ex: ["000200007", 24]
        def top_device_media_download
          @top_device_media_download ||= device_media_downloads.max_by { |k,v| v }
        end

        # returns a hash of media ids and their view counts
        # Ex: {"000200007"=>24, "000200012"=>10}
        def media_views
          @views ||= Morphosource::Analytics::WorkViewStat
                     .where(work_id: media_ids)
                     .group_by { |stat| stat.work_id }
                     .transform_values { |stat| stat.map(&:work_views).sum }
        end

        # returns a hash of media ids and their view counts
        # Ex: {"000200007"=>24, "000200012"=>10}
        def object_media_views
          @object_media_views ||= media_views.dup.extract!(*object_media_ids)
        end

        # returns a hash of media ids and their view counts
        # Ex: {"000200007"=>24, "000200012"=>10}
        def device_media_views
          @device_media_views ||= media_views.dup.extract!(*device_media_ids)
        end

        # returns the total view count for all object and device media
        # Ex: 34
        def view_count
          @view_count ||= media_views.map { |view| view.last }.sum
        end

        # returns the total view count for all object media
        # Ex: 24
        def object_media_view_count
          @object_media_view_count ||= object_media_views.map { |view| view.last }.sum
        end

        # returns the total view count for all device media
        # Ex: 10
        def device_media_view_count
          @device_media_view_count ||= device_media_views.map { |view| view.last }.sum
        end

        # returns an array containing the top viewed media id and its view count
        # Ex: ["000200007", 24]
        def top_view
          @top_view ||= media_views.max_by { |k,v| v }
        end

        # returns an array containing the top viewed object media id and its view count
        # Ex: ["000200007", 24]
        def top_object_media_view
          @top_object_media_view ||= object_media_views.max_by { |k,v| v }
        end

        # returns an array containing the top viewed device media id and its view count
        # Ex: ["000200007", 24]
        def top_device_media_view
          @top_device_media_view ||= device_media_views.max_by { |k,v| v }
        end
      end

    end
  end
end