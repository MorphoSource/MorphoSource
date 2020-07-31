module Morphosource
  module Users
    module CartItems

      # Methods for managing download requests
      include Morphosource::Users::CartItems::ManageRequests
      # Methods for items requested by user
      include Morphosource::Users::CartItems::MyRequests
      # Methods for managing previous downloads
      include Morphosource::Users::CartItems::MyDownloads
      # Methods for managing the user media cart
      include Morphosource::Users::CartItems::MyCart

    end
  end
end
