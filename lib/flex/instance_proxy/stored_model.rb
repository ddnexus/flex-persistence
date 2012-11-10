module Flex
  module InstanceProxy
    class StoredModel < Model

      def store(vars={})
        return super unless instance.flex_indexable? # this should never happen since flex_indexable? returns true
        vars[:data] ||= instance.flex_source
        hash = metainfo.deep_merge(vars)
        instance.new_record? ? Flex.post_store(hash) : Flex.store(hash)
      end

    end
  end
end
