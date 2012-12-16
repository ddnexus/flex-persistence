module Flex
  module InstanceProxy
    class StoredModel < Model

      def store(*vars)
        return super unless instance.flex_indexable? # this should never happen since flex_indexable? returns true
        vars[:data] ||= instance.flex_source
        instance.new_record? ? Flex.post_store(metainfo, *vars) : Flex.store(metainfo, *vars)
      end

    end
  end
end
