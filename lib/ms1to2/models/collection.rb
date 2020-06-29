module Ms1to2
  module Models
    class Collection < BaseObject
      def mappings
        {
          :name => :title,
          :abstract => :description,
          :created_on => :date_uploaded,
          :full_access_users => :editors,
          :read_access_users => :downloaders
        }
      end

      def expected_special_fields
        [:depositor, :visibility]
      end
    end
  end
end 