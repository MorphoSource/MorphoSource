module Ms1to2
  module Models
    class OrganizationFromFacility < BaseObject
      def mappings
        {
          :institution => :title,
          :city => :city,
          :state_province => :stateprov,
          :country => :country,
          :created_on => :date_uploaded
        }
      end

      def expected_special_fields
        [:depositor]
      end
    end
  end
end