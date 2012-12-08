module Flex
  module Persistence
    module FlexResult

      def flex_result(result)
        vars   = result.variables
        freeze = !!vars[:params][:fields]
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

      def build_object(doc, freeze)
        attrs  = (doc['_source']||{}).merge(doc['fields']||{})
        object = new attrs
        object.instance_eval do
          @_id      = doc['_id']
          @_version = doc['_version']
        end
        (freeze || doc['fields']) ? object.freeze : object
      end

      def collection_extend(result, total, vars)
        result.extend Result::Collection
        result.setup total, vars
        result
      end
    end
  end
end
