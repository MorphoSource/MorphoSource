# frozen_string_literal: true

module Morphosource
  module Works
    class Base < ActiveFedora::Base
      include Morphosource::AccessControls::Permissions
      include Morphosource::Works::IndexRelatedWorks

      class_attribute :work_parents_attributes
      class_attribute :work_requires_files
      class_attribute :valid_parent_concerns

      after_update :index_related_works

      self.work_requires_files = false

      def self.valid_parent_concerns
        concerns = Morphosource::Works::Base.descendants
        concerns.each_with_object([]) do |model, parents|
          if model.valid_child_concerns.include? self
            parents << model
          end
        end
      end

      def self.all_solr
        Morphosource::SolrService.new.get_docs("#{Solrizer.solr_name('has_model', :symbol)}:#{name}")
      end

      def descendants
        @descendants = ActiveFedora::Base.find(member_ids)
        get_all_children(@descendants)
        @descendants.flatten.uniq
      end

      def ancestors
        @ancestors = member_of
        get_all_parents(@ancestors)
        @ancestors.flatten.uniq
      end

      def specimen?
        self.class == BiologicalSpecimen
      end

      def cho?
        self.class == CulturalHeritageObject
      end

      def physical_object?
        self.class == BiologicalSpecimen || self.class == CulturalHeritageObject
      end

      def organization?
        self.class == Organization
      end

      def media?
        self.class == Media
      end

      def imaging_event?
        self.class == ImagingEvent
      end

      def processing_event?
        self.class == ProcessingEvent
      end

      def device?
        self.class == Device
      end

      def user_with_ownership
        User.find_by(ms_id: owner)&.ms_id || depositor
      end

      def attachment(field_name)
        Morphosource::AttachmentService.get(self, field_name)
      end

      def member_of_public_collection_ids
        member_of_collections.select { |c| c.visibility == 'open' }.map(&:id)
      end

      def apply_owner_metadata(owner)
        owner_id = owner.respond_to?(:user_key) ? owner.user_key : owner

        if respond_to? :owner
          self.owner = owner_id
        end
        self.edit_users += [owner_id]
        true
      end

      private

      def get_all_children(objects)
        objects.flatten.each do |object|
          next if object.member_ids.blank?

          children = ActiveFedora::Base.find(object.member_ids)
          @descendants << children
          get_all_children(children)
        end
      end

      def get_all_parents(objects)
        objects.flatten.each do |object|
          next if object.member_of.blank?

          parents = object.member_of
          @ancestors << parents
          get_all_parents(parents)
        end
      end
    end
  end
end
