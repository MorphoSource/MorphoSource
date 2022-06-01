class BatchSubmission < ApplicationRecord
  include ActiveModel::Model

  attr_accessor :form_data,
                :work_data,
                :organization_search,
                :device_organization_search,
                :device_id,
                :collection_id,
                :collection_name,
                :on_behalf_of,
                :fund_code,
                :modality

end
