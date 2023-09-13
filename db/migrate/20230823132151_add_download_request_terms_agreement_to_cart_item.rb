class AddDownloadRequestTermsAgreementToCartItem < ActiveRecord::Migration[5.2]
  def change
    add_column :cart_items, :download_request_terms_agreement, :boolean
  end
end
