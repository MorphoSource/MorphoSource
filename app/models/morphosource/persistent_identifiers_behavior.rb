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
      when 'Device'
        return 'Instrument'
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
        if visibility_changed
          ark_identifier = Ezid::Identifier.find(self.ark.first)
          if %w{reserved unavailable}.include?(ark_identifier.status) && public_visibilities.include?(self_visibility)
            ark_identifier.status = 'public'
            ark_identifier.save
          elsif (ark_identifier.status == 'public') && (!public_visibilities.include?(self_visibility))
            ark_identifier.status = 'unavailable'
            ark_identifier.save
          end
        end
      end
    end

    def visibility_changed
      if self.class.to_s == 'Media'
        self.fileset_accessibility_changed?
      else
        self.visibility_changed?
      end
    end

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
        Rails.application.routes.url_helpers.media_showcase_url(:host => ENV['EZID_TARGET_HOST'], id: self.id)
      when 'Device'
        Rails.application.routes.url_helpers.hyrax_device_url(:host => ENV['EZID_TARGET_HOST'], id: self.id)
      when 'BiologicalSpecimen'
        Rails.application.routes.url_helpers.specimen_showcase_url(:host => ENV['EZID_TARGET_HOST'], id: self.id)        
      when 'CulturalHeritageObject'
        Rails.application.routes.url_helpers.cho_showcase_url(:host => ENV['EZID_TARGET_HOST'], id: self.id)        
      when 'OrganizationCollection'
        Rails.application.routes.url_helpers.organization_collection_url(:host => ENV['EZID_TARGET_HOST'], id: self.id)
      end
    end

    def mint_ark
      return if Rails.env.test? # avoid ARK creation in test environment
      if self.ark.empty?
        %w{DEFAULT_SHOULDER USER PASSWORD TARGET_HOST}.each do |required_env_variable|
          if ENV["EZID_#{required_env_variable}"].blank?
            Rails.logger.error("Error minting ARK: #{required_env_variable} environment variable not set")
            return true
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
        requested_ark = "#{ENV['EZID_DEFAULT_SHOULDER']}/#{self.id.sub(/^0*/,'')}"
        begin
          minted_ark = Ezid::Identifier.create(requested_ark, ark_metadata)
        rescue => e
          Rails.logger.error("Error minting ARK: Work #{self.id} not set. Exception: #{e.message}")
        end
        unless minted_ark.nil?
          self.ark = [minted_ark.id]
          self.save
        end
        return true
      end
    end

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