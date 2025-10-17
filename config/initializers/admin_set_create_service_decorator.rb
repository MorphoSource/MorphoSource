module HyraxAdminSetCreateServiceDecorator
  # During Valkyrie transition, persist legacy AF AdminSet when Valkyrie PG AdminSetResource is created
  def create!
    created_admin_set = super
    Rails.logger.info "[Hyrax::AdminSetCreateServiceDecorator] Primary Valkyrie AdminSet created"

    if Hyrax.config.valkyrie_transition? && created_admin_set.persisted?
      Rails.logger.info "[Hyrax::AdminSetCreateServiceDecorator] Persisting secondary AF AdminSet"
      af_admin_set = Wings::ActiveFedoraConverter.convert(resource: created_admin_set)
      af_admin_set.save!
    end

    created_admin_set
  end
end

Rails.application.config.to_prepare do
  Hyrax::AdminSetCreateService.prepend(HyraxAdminSetCreateServiceDecorator)
end