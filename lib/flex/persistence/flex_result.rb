module Flex
  module Persistence
    module FlexResult

      def flex_result(result, vars)
        return result if vars[:raw_result]
        freeze = vars[:params] && !!vars[:params][:fields]
        case result
        when Flex::Result::Document
          build_object result, freeze
        when Flex::Result::Search
          res = result['hits']['hits'].map {|d| build_object(d, freeze)}
          collection_extend res, result['hits']['total'], vars
        when Flex::Result::MultiGet
          res = result['docs'].map {|d| build_object(d, freeze)}
          collection_extend res, res.size, vars
        else
          result
        end
      end

    private

      def build_object(result, freeze)
        object = new(freeze ? result['fields'] : result['_source'])
        object.instance_eval do
          @_id      = result['_id']
          @_version = result['_version']
        end
        freeze ? object.freeze : object
      end

      def collection_extend(result, total, vars)
        result.extend Result::Collection
        result.setup total, vars
        result
      end
    end
  end
end
