module Morphosource
  class OrderedItemsController < ApplicationController

    def index
      # list the items in the right order
      @ordered_items = OrderedItem.order(:position)
    end

    def sort
      media_list = Collection.find(params[:collection_id])
      media_list.ordered_media = Array(params[:media].join(","))
      media_list.save!
    end

  end
end