class AddReviewerToCartItems < ActiveRecord::Migration[5.2]
  def change
    add_column :cart_items, :reviewers, :string, array: true, default: []
  end
end
