module Flex
  module ClassProxy
    module StoredModel

      def init(vars={})
        variables.deep_merge! vars
      end

      def sync(*synced)
        raise ArgumentError, 'You cannot flex.sync(self) a Flex::StoredModel.' \
              if synced.any?{|s| s == host_class}
        super
      end

    end
  end
end
