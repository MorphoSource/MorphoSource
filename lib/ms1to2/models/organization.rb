module Ms1to2
  module Models
    class Organization < BaseObject
      def mappings
        {
          :name => :title,
          :description => :description,
          :city => :location_city,
          :state_province => :location_state,
          :country => :location_country,
          :created_on => :date_uploaded
        }
      end

      def expected_special_fields
        [:depositor]
      end
    end
  end
end