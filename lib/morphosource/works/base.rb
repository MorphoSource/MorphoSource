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

      after_destroy :remove_solr_record

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

      def ancestor_find(cond_method)
        objects = member_of
        return find_parent(objects, cond_method)
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

      def controlled_value_filter
        # This method is used for values either ingested through batch submission, or
        # sync'ed from external soource (iDigBio)
        # Converts the attribute value by:
        # - strips out leading and ending spaces
        # - convert the case to match the controlled list value
        controlled_attributes.each do |attr, service|
          # if needed to check attribute changed?, call self.send(attr.to_s+"_changed?") here
          self.send(attr.to_s+"=", self.send(attr).collect { |e| e ? service.controlled_value(e.strip) : e })
        end
      end

      def date_filter
        # Convert date strings ingested through batch submission (or manual update)
        # Acceptable system date format is YYYY-MM-DD with leading zero's, e.g.
        #  5-6-2019 or 5/6/2019 or 2019/5/6  to 2019-05-06
        date_attributes_for_filter.each do |attr|
          if self.send(attr.to_s+"_changed?")
            str = self.send(attr)&.first
            case str
            when /^(\d{4})[\-\/](\d{1,2})[\-\/](\d{1,2})$/
              str = $1 + "-" + $2.rjust(2, "0") + "-" + $3.rjust(2, "0") if Date.valid_date? $1.to_i, $2.to_i, $3.to_i
            when /^(\d{1,2})[\-\/](\d{1,2})[\-\/](\d{4})$/
              str = $3 + "-" + $1.rjust(2, "0") + "-" + $2.rjust(2, "0") if Date.valid_date? $3.to_i, $1.to_i, $2.to_i
            when nil
              str = ''
            else
              # leave str as it is
            end
            self.send(attr.to_s+"=", [str])
          end
        end
      end
      
      private

      # if everything is working as it should be, the solr document should already have been deleted before this.
      # catch solr docs that fall through the cracks for some unknown reason.
      def remove_solr_record
        begin
          SolrDocument.find(id)
          ActiveFedora::SolrService.delete(id)
        rescue
        end
      end

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

      def find_parent(objects, cond_method)
        objects.flatten.each do |object|
          if object.send(cond_method)
            return object
          else
            parent_result = find_parent(object.member_of, cond_method)
            return parent_result if parent_result.present?
          end
        end
        return nil
      end
    end
  end
end
