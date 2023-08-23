# frozen_string_literal: true

module Morphosource
  module Import
    module SlideSeries
      class CreateSlideRecordsService

        def self.call
          new.call
        end

        def call
          providers.each do |provider|
            @provider = provider
            create_organization
            create_manager
            create_reviewer
            create_device
          end
        end

        def create_organization
          return if @organization = Organization.where(id: @provider['id'])&.first

          organization = Organization.new
          attributes = { id: @provider['id'],
                         title: Array(@provider['label'] || @provider['publisher'] || ["Provider #{@provider['id']}"]),
                         agreement_uri: @provider['agreement_uri'],
                         download_permission: @provider['fileset_accessibility'] || [],
                         license: @provider['license'] || [],
                         morphosource_use_agreement_type: @provider['morphosource_use_agreement_type'] || [],
                         required_archival_of_published_derivatives: @provider['required_archival_of_published_derivatives'] || [],
                         permits_commercial_use: @provider['permits_commercial_use'] || [],
                         permits_3d_use: @provider['permits_3d_use'] || [],
                         publisher: @provider['publisher'] || [],
                         rights_holder: @provider['rights_holder'] || [],
                         rights_statement: @provider['rights_statement'] || [],
                         preview_mode: @provider['preview_mode'] || [],
                         visibility: 'open' }

          Hyrax::CurationConcern.actor.create(Hyrax::Actors::Environment.new(organization, ::Ability.new(admin), attributes))

          @organization = organization.reload
        end

        def create_device
          return unless device_name = @provider['default_device']

          return if @organization.devices.map { |d| d.title.first }.include? device_name

          device = Device.new

          attributes = { title: [device_name],
                         modality: ['SequentialSectionScan'],
                         visibility: 'open' }

          Hyrax::CurationConcern.actor.create(Hyrax::Actors::Environment.new(device, ::Ability.new(admin), attributes))

          @organization.ordered_members << device
          @organization.save!
        end

        def create_manager
          return unless ms_id = @provider['manager']

          create_user(ms_id, 'data_manager')
        end

        def create_reviewer
          return unless ms_id = @provider['download_reviewer']

          create_user(ms_id, 'download_reviewer')
        end

        def create_user(ms_id, role)
          return if User.find_by(ms_id: ms_id)

          user = User.new(email: "#{@provider['id']}_#{role}@example.com", password: 'password', ms_id: ms_id)
          user.skip_confirmation!
          user.save!
          user.make_contributor
        end

        def providers
          @providers ||= YAML.load_file('config/import/slides/providers.yml') || {}
        end

        def admin
          User.all.detect(&:admin?)
        end

      end
    end
  end
end