module Flex
  module Persistence
    module FlexResult

      def flex_result(result)
        vars   = result.variables
        freeze = !!vars[:params][:fields]
        result = super
        if result.is_a?(Array)
          res = result.map {|d| build_object(d, freeze)}
          res.extend Result::Collection
          res.setup result.size, vars
          res
        else
          build_object result, freeze
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

    end
  end
end
