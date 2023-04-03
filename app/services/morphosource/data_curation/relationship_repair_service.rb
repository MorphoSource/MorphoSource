module Morphosource
  module DataCuration
    class RelationshipRepairService

      # Takes either a single media id or an array of ids to repair.
      # Broken relationships can be found by searching for media without physical objects: Morphosource::SolrService.new.get_docs("has_model_ssim:Media NOT physical_object_id_ssim:*")
      # Intended for situations where a user manually submits a media and all of the works are created, but for some reason one or more are lacking parent/child relationships.
      # For each media, prepares a work list of preceding imaging and processing events by working backwards from the media according to Fedora id.
      # For each work in the sorted work list, adds the following work as an ordered member, unless an ordered member already exists.
      # Only repairs unlinked chains of neighboring imaging events, processing events, and media.
      # If there are no event works preceding the media, or a work does not exist for the preceding id, no action is taken, and the media id is reported as being unable to be repaired.
      # Verifies that the service worked after any events/media are linked; if the media's solr record still does not have a physical object id, the media is reported as being unable to be repaired.

      def self.call(media_id: nil)
        new(media_id: media_id).call
      end

      def initialize(media_id: nil)
        @broken_media_ids = []
        @media_id = media_id
      end

      def call
        begin
          update_media
        rescue
          puts "One or more required parameters is not present or incorrect"
        end
        broken_media_search
        puts 'RelationshipRepairService media update complete.'
        puts "Media: #{@broken_media_ids.join(', ')} not able to be repaired." unless @broken_media_ids.empty?
        puts "#{@broken_media_count} media on MorphoSource with broken associations: #{@broken_media_records}"
      end

      private

        def update_media
          Array(@media_id).each do |id|
            repair_hierarchy(id)
          end
        end

        def repair_hierarchy(id)
          @media = Media.find(id)
          works_list = prepare_list
          repair_relationships(works_list)
          return if @broken_media_ids.include? @media.id
          verify_relationships
        end

        def prepare_list
          previous_work = ProcessingEvent.new
          works_list = []
          id = @media.id.to_i - 1
          while (previous_work.event?) do
            work_id = id.to_s.rjust(9,'0')
            begin
              previous_work = ActiveFedora::Base.find(work_id)
            rescue
              @broken_media_ids << @media.id && return
            end
            if previous_work.event?
              works_list << previous_work
            end
            id -= 1
          end
          works_list.sort_by! { |work| work.id }
        end

        def repair_relationships(works_list)
          works_list.each_with_index do |work, index|
            if index < works_list.count
              next if work.ordered_members.to_a.present?

              next_work = works_list[index + 1] || @media
              work.ordered_members << next_work
              work.save!
            end
          end
        end

        def verify_relationships
          if @media.to_solr["physical_object_id_ssim"].present?
            @media.update_index
            puts "Relationships repaired for #{@media.id}"
          else
            @broken_media_ids << @media.id
          end
        end

        def broken_media_search
          docs = Morphosource::SolrService.new.get_docs("has_model_ssim:Media NOT physical_object_id_ssim:*")
          @broken_media_count = docs.count
          @broken_media_records = docs.map { |d| d["id"] }
        end

    end
  end
end
