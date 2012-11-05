module Flex
  module Persistence
    module Result

      def flex_result(result)
        case result
        when Flex::Result::SourceDocument
          build_object result
        when Flex::Result::SourceSearch
          result['hits']['hits'].map {|d| build_object(d)}
        else
          result
        end
      end

    private

      def build_object(result)
        object          = new result['_source']
        object._id      = result['_id']
        object._version = result['_version']
        object
      end

    end
  end
end
