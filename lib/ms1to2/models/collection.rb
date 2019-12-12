module Ms1to2
  module Models
    class Collection < BaseObject
      def mappings
        {
          :name => :title,
          :abstract => :description,
          :created_on => :date_uploaded
        }
      end

      def expected_special_fields
        [:depositor]
      end
    end
end
end 