module Flex
  module InstanceProxy
    class StoredModel < Model

      def store(vars={})
        if instance.flex_indexable?
          hash = metainfo.merge(:data => instance.flex_source).merge(vars)
          instance.new_record? ? Flex.post_store(hash) : Flex.store(hash)
        else
          Flex.remove(metainfo.merge(vars)) if Flex.get(metainfo.merge(vars.merge(:raise => false)))
        end
      end

    end
  end
end
