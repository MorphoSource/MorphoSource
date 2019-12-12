module Ms1to2
  module Models
    class ProcessingEvent < BaseObject
      def mappings
        {
          :scanner_technicians => :creator,
          :created_on => :date_uploaded
        }
      end

      def expected_special_fields
        [:depositor, :parent_id]
      end
    end
  end
end