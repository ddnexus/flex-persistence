module Flex
  module Persistence
    class Scoped < Hash

      include Structure::Mergeable

      # never instantiate this object directly: it is automatically done by the StoredModel.scoped method
      def initialize(model_class)
        @model_class = model_class
        replace @model_class.flex.variables
      end

      # accepts also :any_term => nil for missing values
      def terms(value)
        deep_merge! self.class.process_terms(value)
        self
      end

      # the standard :params variable
      def params(value)
        deep_merge! :params => value
        self
      end

      # accepts one or an array of filter structures
      def filters(value)
        process_array :filters, value
        self
      end

      # accepts one or an array of sort structures documented in http://www.elasticsearch.org/guide/reference/api/search/sort.html
      # doesn't support the multiple hash form, but you can pass an hash as single argument or an array of hashes
      def sort(value)
        process_array :sort, value
        self
      end

      # the fields that you want to retrieve (limiting the size of the response)
      # the returned records will be frozen, and the missing fileds will be nil
      # pass a comma separated (no space) string e.g. 'field_one,field_two'
      def fields(value)
        params(:fields => value)
        self # just for simmetry
      end

      # it limits the size of the query to 1 and returns it as a single document object
      def first
        result = Persistence.find params(:size => 1)
        @model_class.flex_result(result, self).first
      end

      # will retrieve all documents, the results will be limited by the default :size param
      # use #scan_all if you want to really retrieve all documents (in batches)
      def all
        result = Persistence.find self
        @model_class.flex_result(result, self)
      end

      # scan_search: the block will be yielded many times with an array of batched results.
      # You can pass :scroll and :size as params in order to control the action.
      # See http://www.elasticsearch.org/guide/reference/api/search/scroll.html
      def scan_all(&block)
        result = @model_class.flex.scan_search(Persistence.flex.templates[:find], self, &block)
        @model_class.flex_result(result, self)
      end

      def count
        result = Persistence.flex.count_search(:find, self)
        result['hits']['total']
      end

      def inspect
        "#<#{self.class.name} #{self}>"
      end

    private

      def self.process_terms(hash)
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
