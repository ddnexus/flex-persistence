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
          result['hits']['hits'].map {|d| build_object(d, freeze)}
        when Flex::Result::MultiGet
          result['docs'].map {|d| build_object(d, freeze)}
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

    end
  end
end
