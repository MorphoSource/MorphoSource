# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource TaxonomyResource`
module Hyrax
  # Generated controller for TaxonomyResource
  class TaxonomyResourcesController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::TaxonomyResource

    # Override default Valkyrie create work transaction
    self.create_valkyrie_work_action.transaction_name = "taxonomy_change_set.create_work"

    # Use a Valkyrie aware form service to generate Valkyrie::ChangeSet style
    # forms.
    self.work_form_service = Hyrax::FormFactory.new

    private

    # Override default Valkyrie update work transaction
    def update_valkyrie_work
      form = build_form
      return after_update_error(form_err_msg(form)) unless form.validate(params[hash_key_for_curation_concern])
      result =
        transactions['taxonomy_change_set.update_work']
        .with_step_args('work_resource.save_acl' => { permissions_params: form.input_params["permissions"] })
        .call(form)
      @curation_concern = result.value_or { return after_update_error(transaction_err_msg(result)) }
      after_update_response
    end
  end
end
