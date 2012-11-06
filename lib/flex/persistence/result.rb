module Flex
  module Persistence
    module Result

      def flex_result(result)
        case result
        when Flex::Result::SourceDocument
          build_object result
        when Flex::Result::Search
          result['hits']['hits'].map {|d| build_object(d)}
        when Flex::Result::MultiGet
          result['docs'].map {|d| build_object(d)}
        else
          result
        end
      end

    private

      def build_object(result)
        object = new result['_source']
        object.instance_eval do
          @_id      = result['_id']
          @_version = result['_version']
        end
        object
      end

    end
  end
end
