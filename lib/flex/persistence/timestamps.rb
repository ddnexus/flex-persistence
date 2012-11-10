module Flex
  module Persistence
    module Timestamps

      def attribute_timestamps
        attribute_created_at
        attribute_updated_at
      end

      def attribute_created_at
        attribute :created_at, :type => DateTime
        before_save { self.created_at = Time.now.utc if new_record? }
      end

      def attribute_updated_at
        attribute :updated_at, :type => DateTime
        before_save { self.updated_at = Time.now.utc }
      end

    end
  end
end
