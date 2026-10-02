module Morphosource
  module Works
    ##
    #
    # New property and methods for AF works to be able to have Valkyrie resources as children
    #
    # As a general rule, although AF works CAN be represented as Valkyrie resources through wings,
    # this module makes an assumption that Valkyrie children and parents have been migrated into
    # postgres and are NOT using wings.
    module ValkyrieAssociation
      extend ActiveSupport::Concern

      ##
      # Proxy array that delegates modification methods to the underlying array
      # and triggers the parent's setter to save changes.
      class HybridMemberProxy < Array
        ##
        # @param parent [ActiveFedora::Base]
        # @param method_name [Symbol, String]
        # @param items [Array]
        def initialize(parent, method_name, items)
          @parent = parent
          @method_name = method_name
          super(items)
        end

        ##
        # @param item [Object]
        # @return [HybridMemberProxy]
        def <<(item)
          super
          sync
          self
        end

        ##
        # @param items [Array<Object>]
        # @return [HybridMemberProxy]
        def push(*items)
          super
          sync
          self
        end

        ##
        # @param item [Object]
        # @return [Object]
        def delete(item)
          result = super
          sync
          result
        end

        ##
        # @return [HybridMemberProxy]
        def clear
          super
          sync
          self
        end

        private

        def sync
          @parent.send("#{@method_name}=", self)
        end
      end

      included do
        property :valkyrie_member_ids, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/valkyrieMemberIds") do |index|
          index.as :symbol
        end

        property :valkyrie_representative_id,
                 predicate: ::RDF::URI.new("https://www.morphosource.org/terms/valkyrieRepresentativeId"),
                 multiple: false

        property :valkyrie_thumbnail_id,
                 predicate: ::RDF::URI.new("https://www.morphosource.org/terms/valkyrieThumbnailId"),
                 multiple: false

        [
          :ordered_members,
          :members
        ].each do |method_name|
          create_method_get_members(method_name)
          create_method_set_members(method_name)
        end

        [
          :ordered_member_ids,
          :member_ids
        ].each do |method_name|
          create_method_get_member_ids(method_name)
        end

        [
          :member_of
        ].each do |method_name|
          create_method_get_member_of(method_name)
        end

        [
          :representative,
          :thumbnail
        ].each do |method_name|
          create_method_get_singular_association(method_name)
          create_method_set_singular_association(method_name)
          create_method_get_singular_association_id(method_name)
          create_method_set_singular_association_id(method_name)
        end
      end

      class_methods do
        ##
        # Defines getter that will return both AF and Valkyrie members
        #
        # @param method_name [Symbol]
        # @return [HybridMemberProxy]
        def create_method_get_members(method_name)
          alias_method "active_fedora_#{method_name}", method_name
          define_method method_name do
            Morphosource::Works::ValkyrieAssociation::HybridMemberProxy.new(
              self,
              method_name,
              (valkyrie_members + super().to_a).uniq { |w| w.id.to_s }
            )
          end
        end

        ##
        # Defines setter to handle both AF and Valkyrie members
        #
        # @param method_name [Symbol]
        def create_method_set_members(method_name)
          alias_method "active_fedora_#{method_name}=", "#{method_name}="
          define_method "#{method_name}=" do |members_collection|
            members_collection ||= []
            valkyrie_items, af_items = members_collection.partition do |member|
              member.is_a?(::Valkyrie::Resource)
            end

            self.valkyrie_member_ids = valkyrie_items.map(&:id).map(&:to_s)
            super(af_items)
          end
        end

        ##
        # Defines getter to return IDs of both AF and Valkyrie members
        #
        # @param method_name [Symbol]
        # @return [Array] IDs of AF and Valkyrie members
        def create_method_get_member_ids(method_name)
          alias_method "active_fedora_#{method_name}", method_name
          define_method method_name do
            (valkyrie_member_ids + super().to_a).uniq
          end
        end

        ##
        # Define getter to return parent works both from AF and Valkyrie
        #
        # @param method_name [Symbol]
        # @return [Array] Parent works both from AF and Valkyrie
        def create_method_get_member_of(method_name)
          alias_method "active_fedora_#{method_name}", method_name
          define_method method_name do
            (valkyrie_member_of + super().to_a).uniq { |w| w.id.to_s }
          end
        end

        ##
        # Defines getter that returns the Valkyrie resource if one is stored,
        # otherwise falls back to the ActiveFedora association object.
        #
        # @param method_name [Symbol] :representative or :thumbnail
        def create_method_get_singular_association(method_name)
          valkyrie_id_property = "valkyrie_#{method_name}_id"
          alias_method "active_fedora_#{method_name}", method_name
          define_method method_name do
            vid = public_send(valkyrie_id_property)
            if vid.present?
              begin
                Hyrax.query_service.postgres_service.find_by(id: vid)
              rescue Valkyrie::Persistence::ObjectNotFoundError
                super()
              end
            else
              super()
            end
          end
        end

        ##
        # Defines setter that routes to Valkyrie ID storage when the object is a
        # Valkyrie::Resource, otherwise delegates to the ActiveFedora setter.
        #
        # @param method_name [Symbol] :representative or :thumbnail
        def create_method_set_singular_association(method_name)
          valkyrie_id_property = "valkyrie_#{method_name}_id"
          alias_method "active_fedora_#{method_name}=", "#{method_name}="
          define_method "#{method_name}=" do |object|
            if object.is_a?(::Valkyrie::Resource)
              self.public_send("#{valkyrie_id_property}=", object.id.to_s)
              send("active_fedora_#{method_name}=", nil)
            else
              self.public_send("#{valkyrie_id_property}=", nil)
              super(object)
            end
          end
        end

        ##
        # Defines getter for the association ID that returns the Valkyrie ID when
        # one is stored, otherwise returns the ActiveFedora ID.
        #
        # @param method_name [Symbol] :representative or :thumbnail
        # @return [String, nil]
        def create_method_get_singular_association_id(method_name)
          valkyrie_id_property = "valkyrie_#{method_name}_id"
          alias_method "active_fedora_#{method_name}_id", "#{method_name}_id"
          define_method "#{method_name}_id" do
            public_send(valkyrie_id_property) || super()
          end
        end

        ##
        # Defines setter for the association ID. Routes to Valkyrie storage when
        # the value is a Valkyrie::ID, otherwise delegates to the ActiveFedora setter
        # and clears any stored Valkyrie ID.
        #
        # @param method_name [Symbol] :representative or :thumbnail
        def create_method_set_singular_association_id(method_name)
          valkyrie_id_property = "valkyrie_#{method_name}_id"
          alias_method "active_fedora_#{method_name}_id=", "#{method_name}_id="
          define_method "#{method_name}_id=" do |id_val|
            if id_val.is_a?(::Valkyrie::ID)
              self.public_send("#{valkyrie_id_property}=", id_val.to_s)
              send("active_fedora_#{method_name}_id=", nil)
            else
              self.public_send("#{valkyrie_id_property}=", nil)
              super(id_val)
            end
          end
        end
      end

      ##
      # For members with .file_set? true, return ID strings. Override from Hydra::Works::WorkBehavior.
      #
      # @return [Array<String>]
      def file_set_ids
        file_sets.map { |fs| fs.id.to_s }
      end

      ##
      # Valkyrie resources that have this AF work stored in their member_ids property
      #
      # @return [Array<Valkyrie::Resource>]
      def valkyrie_member_of
        return [] unless id.present?
        Hyrax.query_service.postgres_service.find_inverse_references_by(id: id, property: :member_ids).to_a
      end

      ##
      # Valkyrie resources for valkyrie members
      #
      # @return [Array<Valkyrie::Resource>]
      def valkyrie_members
        valkyrie_member_ids.map do |id|
          Hyrax.query_service.postgres_service.find_by(id: id)
        rescue Valkyrie::Persistence::ObjectNotFoundError
          next
        end.compact
      end

      ##
      # The Valkyrie resource stored as representative, if any.
      #
      # @return [Valkyrie::Resource, nil]
      def valkyrie_representative
        return nil if valkyrie_representative_id.blank?
        Hyrax.query_service.postgres_service.find_by(id: valkyrie_representative_id)
      rescue Valkyrie::Persistence::ObjectNotFoundError
        nil
      end

      ##
      # The Valkyrie resource stored as thumbnail, if any.
      #
      # @return [Valkyrie::Resource, nil]
      def valkyrie_thumbnail
        return nil if valkyrie_thumbnail_id.blank?
        Hyrax.query_service.postgres_service.find_by(id: valkyrie_thumbnail_id)
      rescue Valkyrie::Persistence::ObjectNotFoundError
        nil
      end
    end
  end
end