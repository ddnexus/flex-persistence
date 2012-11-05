module Flex
  module ClassProxy
    class StoredModel < Model

      def sync(*synced)
        raise ArgumentError, 'You cannot flex.sync(self) a Flex::StoredModel.' \
              if synced.any?{|s| s == host_class}
        super
      end

    end
  end
end
