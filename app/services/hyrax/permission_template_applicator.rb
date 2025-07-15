# frozen_string_literal: true
module Hyrax
  ##
  # Applies a `PermissionTemplate` to a given model object by adding the
  # template's manage and view users to the model's permissions.
  #
  # @example applying a template
  #   applicator = PermissionTemplateApplicator.new(template: my_template)
  #   applicator.apply_to(work)
  #
  # @example applying a template with fluent chaining syntax
  #   PermissionTemplateApplicator.apply(my_template).to work
  #
  # @since 2.4.0
  class PermissionTemplateApplicator
    ##
    # @!attribute [rw] template
    #   @return [Hyrax::PermissionTemplate]
    attr_accessor :template

    ##
    # @param template [Hyrax::PermissionTemplate]
    def initialize(template:)
      self.template = template
    end

    ##
    # @param template [Hyrax::PermissionTemplate]
    #
    # @return [PermissionTemplateApplicator]
    def self.apply(template)
      new(template: template)
    end

    ##
    # @param model [Hydra::PCDM::Object, Hydra::PCDM::Collection]
    # @return [Boolean] true if the permissions have been successfully applied
    def apply_to(model:)
      puts "!!!!!!!! Applying permission template #{template.id} to #{model.id} (#{model.class})"
      model.edit_groups += (template.agent_ids_for(agent_type: 'group', access: 'manage') - model.edit_groups)
      puts "!!!!!!!! Adding edit groups: #{template.agent_ids_for(agent_type: 'group', access: 'manage') - model.edit_groups}"
      # add edit access for collection editors group
      model.edit_groups += (template.agent_ids_for(agent_type: 'group', access: 'edit_works') - model.edit_groups)
      puts "!!!!!!!! Adding edit users: #{template.agent_ids_for(agent_type: 'user', access: 'manage') - model.edit_users}"
      model.edit_users  += (template.agent_ids_for(agent_type: 'user', access: 'manage') - model.edit_users)
      puts "!!!!!!!! model.download_groups: #{model.download_groups}"
      puts "!!!!!!!! Adding download groups: #{template.agent_ids_for(agent_type: 'group', access: 'download') - model.download_groups}"
      # add download access for collection downloaders group
      puts "!!!!!!! output of adding download groups:"
      puts (model.download_groups += (template.agent_ids_for(agent_type: 'group', access: 'download') - model.download_groups))
      model.download_groups += (template.agent_ids_for(agent_type: 'group', access: 'download') - model.download_groups)
      puts "!!!!!!! Added download groups: #{model.reload.download_groups}"
      puts "!!!!!!!! Adding read groups: #{template.agent_ids_for(agent_type: 'group', access: 'view') - model.read_groups}"
      model.read_groups += (template.agent_ids_for(agent_type: 'group', access: 'view') - model.read_groups)
      puts "!!!!!!!! Adding read users: #{template.agent_ids_for(agent_type: 'user', access: 'view') - model.read_users}"
      model.read_users  += (template.agent_ids_for(agent_type: 'user', access: 'view') - model.read_users)
      puts "!!!!!!!! Updated model #{model.id} (#{model.class}) with permission template #{template.id}"
      true
    rescue StandardError => e
      puts e
      puts "!!!!!!!! Error applying permission template #{template.id} to #{model.id} (#{model.class}): #{e.message}"
    end
    alias to apply_to

  end
end
