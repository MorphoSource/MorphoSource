module Morphosource
  module Import
    module Slides
      module SlideSeries
        module Sources

          extend ActiveSupport::Concern

          delegate :sources, :org_key, :org_key_field, to: :class

          class_methods do

            def sources
              @sources ||= YAML.load_file('config/import/slides/sources.yml')
            end

            # Ex: publishingOrgKey
            def org_key_field
              @org_key_field ||= sources[@source]['org_key']
            end

            def org_key
              @org_key ||= @json[org_key_field]
            end
          end

          def organization
            @organization ||= Organization.find(org_id)
          end

          def org_id
            sources[@source]['organizations'][org_key]['ms_id']
          end

          # Ex: publishingOrgKey
          def org_key_field
            @org_key_field ||= sources[@source]['org_key']
          end

          def org_key
            @org_key ||= @json[org_key_field]
          end

        end
      end
    end
  end
end