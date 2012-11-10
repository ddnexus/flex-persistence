module Flex
  module Persistence
    class Scoped < Hash

      include Structure::Mergeable

      def initialize(model)
        @model_class = model
        replace @model_class.flex.variables
      end

      def terms(value)
        deep_merge! process_terms(value)
        self
      end

      def params(value)
        deep_merge! :params => value
        self
      end

      def filters(value)
        process_array :filters, value
        self
      end

      def sort(value)
        process_array :sort, value
        self
      end

      def fields(value)
        params(:fields => value)
        self # just for simmetry
      end

      def first
        result = Persistence.find params(:size => 1)
        @model_class.flex_result(result, self).first
      end

      def all
        result = Persistence.find self
        @model_class.flex_result(result, self)
      end

      def scan_all(&block)
        result = @model_class.flex.scan_search(Persistence.flex.templates[:find], self, &block)
        @model_class.flex_result(result, vars)
      end

      def count
        result = Persistence.flex.count_search(:find, self)
        result['hits']['total']
      end

      def inspect
        "#<#{self.class.name} #{self}>"
      end

      private

      def process_terms(hash)
        clean_terms    = {}
        missing_fields = []
        hash.each { |f, v| v.nil? ? missing_fields.push({ :missing => f }) : (clean_terms[f] = v) }
        {:terms => clean_terms, :_missing_fields => missing_fields}
      end

      def process_array(name, value)
        self[name] ||= []
        if value.is_a?(Array)
          self[name] += value
        else
          self[name] << value
        end
      end

    end
  end
end
