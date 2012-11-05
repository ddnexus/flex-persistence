module Flex
  module Persistence
    module Find

      def find(id_or_ids)
        result = if id_or_ids.is_a?(Array)
                   Flex.multi_get metainfo(:ids => id_or_ids)
                 else
                   Flex.get metainfo(:id => id_or_ids)
                end
        flex_result(result)
      end

      def all
        result = Flex.match_all metainfo
        flex_result result
      end

      def count
        result = Flex.count metainfo
        result['count']
      end

      def first
        result = Flex.match_all metainfo(:params => {:size => 1})
        flex_result(result).first
      end

      # 2 queries needed
      def last
        result = Flex.match_all metainfo(:params => {:size => 1, :from => count-1})
        flex_result(result).first
      end

    private

      def metainfo(vars={})
        { :index => flex.index, :type => flex.type }.merge(vars)
      end

    end
  end
end
