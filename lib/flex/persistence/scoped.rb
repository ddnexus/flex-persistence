module Flex
  module Persistence
    class Scoped < Hash

      class Error < StandardError; end

      include Structure::Mergeable

      # never instantiate this object directly: it is automatically done by the StoredModel.scoped method
      def initialize(model_class)
        @model_class = model_class
        replace @model_class.flex.variables
      end

      # accepts also :any_term => nil for missing values
      def terms(hash)
        terms, missing_fields = {}, []
        hash.each { |f, v| v.nil? ? missing_fields.push({ :missing => f }) : (terms[f] = v) }
        deep_merge :terms => terms, :_missing_fields => missing_fields
      end

      # the standard :params variable
      def params(value)
        deep_merge :params => value
      end

      # accepts one or an array or a list of filter structures
      def filters(*value)
        deep_merge :filters => array_value(value)
      end

      # accepts one or an array or a list of sort structures documented in http://www.elasticsearch.org/guide/reference/api/search/sort.html
      # doesn't probably support the multiple hash form, but you can pass an hash as single argument or an array or list of hashes
      def sort(*value)
        deep_merge :sort => array_value(value)
      end

      # the fields that you want to retrieve (limiting the size of the response)
      # the returned records will be frozen, and the missing fileds will be nil
      # pass an array eg fields.([:field_one, :field_two])
      # or a list of fields e.g. fields(:field_one, :field_two)
      def fields(*value)
        deep_merge :params => {:fields => array_value(value)}
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
        template = Persistence.flex.templates[:find]
        result   = @model_class.flex.scan_search(template, self, &block)
        @model_class.flex_result(result, self)
      end

      # performs a count search on the scope
      def count
        result = Persistence.flex.count_search(:find, self)
        result['hits']['total']
      end

      def inspect
        "#<#{self.class.name} #{self}>"
      end

      def respond_to?(meth, private=false)
        super || @model_class.scopes.include?(meth.to_sym)
      end

      def method_missing(meth, *args, &block)
        super unless respond_to?(meth)
        deep_merge @model_class.send(meth, *args)
      end

    private

      def array_value(value)
        value.first if value.first.is_a?(Array) && value.size == 1
      end

    end
  end
end
