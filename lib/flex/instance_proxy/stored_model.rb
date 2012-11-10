module Flex
  module InstanceProxy
    class StoredModel < Model

      def store(vars={})
        if instance.flex_indexable?
          vars[:data] ||= instance.flex_source
          hash = metainfo.deep_merge(vars)
          instance.new_record? ? Flex.post_store(hash) : Flex.store(hash)
        else
          Flex.remove(metainfo.deep_merge(vars)) if Flex.get(metainfo.deep_merge(vars.merge(:raise => false)))
        end
      end

    end
  end
end
