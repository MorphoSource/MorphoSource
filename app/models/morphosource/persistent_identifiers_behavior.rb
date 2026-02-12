module Morphosource
  module PersistentIdentifiersBehavior

    def ark_resource_type
      # Valid ARK resource types:
      # 'Audiovisual', 'Collection', 'DataPaper', 'Dataset', 'Event', 'Image',
      # 'InteractiveResource', 'Model', 'PhysicalObject', 'Service', 'Software',
      # 'Sound', 'Text', 'Workflow', 'Other'
      # These are defined in resourceTypeGeneral in the DataCite Metadata Schema:
      # http://schema.datacite.org/meta/kernel-4.3/
      case self.class.to_s
      when 'Media'
        ark_resource_type_mappings = {
          'Video' => 'Audiovisual',
          'Mesh' => 'Image',
          'CTImageSeries' => 'Collection',
          'PhotogrammetryImageSeries' => 'Collection'
        }
        if ark_resource_type_mappings.key?(self.media_type.first)
          return ark_resource_type_mappings[self.media_type.first]
        else
          return self.media_type.first
        end
      when 'BiologicalSpecimen', 'CulturalHeritageObject'
        return 'PhysicalObject'
      when 'Device', 'DeviceResource'
        # todo: currently getting an error invalid resource type 'Instrument' when the record is "public". 
        # change this back to "Instrument" when the issue is resolved
        return 'Service'
      when 'OrganizationCollection'
        return 'Service'
      else
        return 'Other'
      end
    end

    # possible ARK status changes:
    # - reserved->public
    # - public->unavailable
    # - unavailable->public
    def update_ark_status
      unless self.ark.empty?
        # visibility_changed no longer works with Valkyrie models, so we are comparing 
        # pevious ARK status with the current visibility instead
        begin
          ark_identifier = Ezid::Identifier.find(self.ark.first)
          if %w{reserved unavailable}.include?(ark_identifier.status) && public_visibilities.include?(self_visibility)
            # ark status was reserved or unavailable, and now we are changing to public
            ark_identifier.status = 'public'
            ark_identifier.save
          elsif (ark_identifier.status == 'public') && (!public_visibilities.include?(self_visibility))
            # ark status was public, and now we are changing to unavailable
            ark_identifier.status = 'unavailable'
            ark_identifier.save
          end
        rescue => e
          Rails.logger.error("Error finding ARK. Exception: #{e.message}")
        end
      end
    end

    # TODO: remove this method later if no longer needed
    # def visibility_changed
    #   if self.class.to_s == 'Media'
    #     self.fileset_accessibility_changed?
    #   else
    #     self.visibility_changed?
    #   end
    # end

    def public_visibilities
      @public_visibilities ||= begin
        if self.class.to_s == 'Media'
          %w{open restricted_download preview_only hidden}
        else
          %w{open}
        end
      end
    end

    def self_visibility
      @visibility ||= begin
        if self.class.to_s == 'Media'
          self.fileset_accessibility.first
        else
          self.visibility
        end
      end
    end

    def datacite_target_url
      case self.class.to_s
      when 'Media'
        Rails.application.routes.url_helpers.media_showcase_url(:host => ENV['EZID_TARGET_HOST'], id: self.id.to_s)
      when 'Device', 'DeviceResource'
        Rails.application.routes.url_helpers.hyrax_device_url(:host => ENV['EZID_TARGET_HOST'], id: self.id.to_s)
      when 'BiologicalSpecimen'
        Rails.application.routes.url_helpers.specimen_showcase_url(:host => ENV['EZID_TARGET_HOST'], id: self.id.to_s)        
      when 'CulturalHeritageObject'
        Rails.application.routes.url_helpers.cho_showcase_url(:host => ENV['EZID_TARGET_HOST'], id: self.id.to_s)        
      when 'OrganizationCollection'
        Rails.application.routes.url_helpers.organization_collection_url(:host => ENV['EZID_TARGET_HOST'], id: self.id.to_s)
      end
    end

    def mint_ark(persister: nil)
      return self if Rails.env.test? # avoid ARK creation in test environment

      if self.ark.empty?
        %w{DEFAULT_SHOULDER USER PASSWORD TARGET_HOST}.each do |required_env_variable|
          if ENV["EZID_#{required_env_variable}"].blank?
            Rails.logger.error("Error minting ARK: #{required_env_variable} environment variable not set")
            return self
          end
        end
        depositor_user = User.find_by(ms_id: self.depositor)
        depositor_user_name_components = depositor_user.display_name.split(' ')
        # DataCite metadata expects creator in the form Lastname, Firstname
        datacite_creator = [depositor_user_name_components.drop(1).join(' '),depositor_user_name_components.first].join(', ')
        ark_status = public_visibilities.include?(self_visibility) ? 'public' : 'reserved'
        ark_metadata = {'_status' => ark_status,
                        '_target' => datacite_target_url,
                        '_profile' => 'datacite',
                        'datacite.identifiertype' => 'ARK',
                        'datacite.creator' => datacite_creator,
                        'datacite.publisher' => 'MorphoSource.org',
                        'datacite.title' => self.title.first,
                        'datacite.publicationyear' => Time.now.year.to_s,
                        'datacite.resourcetypegeneral' => self.ark_resource_type
        }
        requested_ark = "#{ENV['EZID_DEFAULT_SHOULDER']}/#{self.id.to_s.sub(/^0*/,'')}"

        begin
          minted_ark = Ezid::Identifier.create(requested_ark, ark_metadata)
        rescue => e
          Rails.logger.error("Error minting ARK: Work #{self.id.to_s} not set. Exception: #{e.message}")
        end

        unless minted_ark.nil?
          self.ark = [minted_ark.id]
          case self.class.to_s
          when 'Device'
            Hyrax.persister.save(resource: self)
            Hyrax.index_adapter.save(resource: self)
          when 'DeviceResource'
            # DeviceResource persistence/indexing is handled by MintWorkArkJob.
          else
            self.save
          end
        end
      end
      self
    end # /mint_ark

    private
    
      def delete_ark_if_reserved
        unless self.ark.empty?
          ark_identifier = Ezid::Identifier.find(self.ark.first)
          if ark_identifier.status == 'reserved'
            ark_identifier.delete
          end
        end
      end

  end
end
