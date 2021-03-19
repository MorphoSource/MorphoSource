module Morphosource
  module Metadata
    class CollectionExport
      attr_accessor :collection_id, :collection, :output_data
      attr_accessor :media, :biological_specimen_object, :cultural_heritage_object, :processing_event, :imaging_event, :device, :organization, :user

      def self.output_data_class
        ::Ms1to2::Ms2OutputData
      end

      def self.call(collection_id, csv_path)
        new(collection_id).call(csv_path)
      end

      def initialize(collection_id)
        if Collection.exists?(collection_id)
          @collection_id = collection_id
          @collection = Collection.find(collection_id)
        end
      end

      def call(csv_path)
        gather_collection_data
        export(csv_path)
      end

      def gather_collection_data
        gather_objects
        models.each { |m| model_to_output(m) }
      end

      def gather_objects
        @media = @collection.member_works
        @biological_specimen_object = unique_works(@media.map { |m| m.specimens }.flatten.compact)
        @cultural_heritage_object = unique_works(@media.map { |m| m.cultural_heritage_objects }.flatten.compact)
        @processing_event = unique_works(@media.map { |m| m.processing_event }.flatten.compact)
        @imaging_event = unique_works(@media.map { |m| m.imaging_event }.flatten.compact)
        @organization = unique_works(@media.map { |m| m.organizations.to_a }.flatten.compact)
        gather_device
        gather_taxonomy
        gather_user
      end

      def gather_device
        @device = unique_works(
          @imaging_event.map { |ie| ie.device_id&.first }.compact.uniq
          .map { |id| Device.find(id) if Device.exists?(id) }.compact
        )
      end

      def gather_taxonomy
        @taxonomy = unique_works(
          @biological_specimen_object.map { |b| Array(b.taxonomy_id) }.flatten.compact.uniq
          .map { |id| Taxonomy.find(id) if Taxonomy.exists?(id) }.compact
        )
      end

      def gather_user
        @user = (Array(@collection) + @media + @biological_specimen_object + @cultural_heritage_object + @processing_event + @imaging_event + @device).map { |o| User.find_by(ms_id: o.depositor) }.compact.uniq
      end

      def export(csv_path)
        output_data.output_path = csv_path
        output_data.export_data
      end

      def models
        [
          'collection', 'media', 'processing_event', 'imaging_event', 'device',
          'biological_specimen', 'taxonomy', 'cultural_heritage_object', 'organization', 'user'
        ]
      end

      # def collection
      #   output_data.collection = create_table(current_collection)
      # end

      # def media
      #   output_data.media = create_table(@media)
      # end


      # def processing_event
      #   output_data.processing_event = create_table(@processing_event)
      # end

      # def imaging_event
      #   output_data.imaging_event = create_table(@imaging_event)
      # end

      # def device
      #   output_data.device = create_table(@device)
      # end

      # def biological_specimen
      #   output_data.biological_specimen = create_table(@biological_specimen_object
      #   )
      # end

      # def taxonomy
      #   output_data.taxonomy = create_table(@taxonomy)
      # end

      # def cultural_heritage_object
      #   output_data.cultural_heritage_object = create_table(@cultural_heritage_object
      #   )
      # end

      # def organization
      #   output_data.organization = create_table(@organization)
      # end

      # def user
      #   output_data.user = create_table(@user)
      # end

      def model_to_output(model)
        output_data.instance_variable_set("@#{model}", create_table(instance_variable_get("@#{model}")))
      end

      def create_table(objects)
        Array(objects).each_with_object({}) do |obj, h|
          h[obj.id] = metadata_attributes(obj)
        end
      end

      private

      def output_data
        @output_data ||= CollectionExport.output_data_class.new
      end

      def metadata_attributes(object)
        object.attributes
          .except(*excluded_attributes)
          .merge(extra_attributes(object))
          .select { |_, v| v.present? }
      end

      def extra_attributes(object)
        if object.is_a? User
          {}
        elsif object.is_a? Media
          { 'parent_id': object.member_of.map { |p| p.id }, 'visibility': object.visibility, 'file': object.file_sets&.first.label }
        else
          { 'parent_id': object.member_of.map { |p| p.id }, 'visibility': object.visibility }
        end
      end

      def unique_works(works) # because .uniq doesn't work here
        works.map(&:id).uniq.map { |id| ActiveFedora::Base.find(id) } 
      end

      def excluded_attributes
        ['head', 'tail', 'access_control_id', 'representative_id', 'thumbnail_id', 'admin_set_id', 'encrypted_password', 'sign_in_count', 'current_sign_in_at', 'last_sign_in_at', 'current_sign_in_ip', 'last_sign_in_ip']
      end
    end
  end
end