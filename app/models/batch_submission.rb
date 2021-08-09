class BatchSubmission < ApplicationRecord
  include ActiveModel::Model

  attr_accessor :form_data,
                :work_data,
                :organization_search

end
