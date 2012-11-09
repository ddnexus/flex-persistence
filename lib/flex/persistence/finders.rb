module Flex
  module Persistence
    module Finders


      #    MyModel.find(ids)
      #    - ids can ba a single id or an array of ids
      #
      #    MyModel.find '1Momf4s0QViv-yc7wjaDCA'
      #      #=> #<MyModel ... color: "red", size: "small">
      #
      #    MyModel.find ['1Momf4s0QViv-yc7wjaDCA', 'BFdIETdNQv-CuCxG_y2r8g']
      #      #=> [#<MyModel ... color: "red", size: "small">, #<MyModel ... color: "bue", size: "small">]
      #
      def find(ids, vars={})
        result = if ids.is_a?(Array)
                   Flex.multi_get(process_vars(:ids => ids).deep_merge(vars))
                 else
                   Flex.get(process_vars(:id => ids).deep_merge(vars))
                 end
        flex_result(result)
      end

      #    MyModel.all(vars={})
      #
      #    vars = { # accepts also :any_term => nil for missing values
      #             :terms   => {:field_one => 'something', :field_two => nil},
      #             # accepts one or an array of sort structures documented in http://www.elasticsearch.org/guide/reference/api/search/sort.html
      #             :sort    => {:field_three => :desc},
      #             # accepts one or an array of filter structures
      #             :filters => {:range => {:created_at => {:from => 2.days.ago, :to => Time.now}}}
      #
      #    # will retrieve all documents, the results will be limited by the default :size param
      #    MyModel.all(vars_or_nil)
      #
      def all(vars={})
        variables = process_vars(vars)
        result    = Persistence.find variables
        flex_result(result)
      end

      #    MyModel.scan_all(vars={}, &block)
      #    - vars are the same kind of Hash described for the method :all
      #    - scan_search: the block will be yielded many times with an array of batched results.
      #      You can pass :scroll and :size as :params in order to control the action.
      #      See http://www.elasticsearch.org/guide/reference/api/search/scroll.html
      #    MyModel.all(vars_or_nil) do |batch_of_results|
      #      do_something_with batch_of_results
      #    end
      #
      def scan_all(vars={}, &block)
        variables = process_vars(vars)
        result    = flex.scan_search(Persistence.flex.templates[:find], variables, &block)
        flex_result(result)
      end

      #    MyModel.first(vars={})
      #    - vars are the same kind of Hash described for the method :all
      #    - it limits the size of the query to 1 and returns it as a single document object
      #
      def first(vars={})
        vars = Variables.new(vars).deep_merge(:params => {:size => 1})
        all(vars).first
      end

      #    MyModel.count(vars={})
      #    - will return the count
      #    - vars are the same kind of Hash described for the method :all
      #
      def count(vars={})
        Persistence.flex.count_search(:find, process_vars(vars))['hits']['total']
      end

    private

      def process_vars(vars)
        terms = process_terms(vars.delete(:terms))
        flex.variables.deep_merge(vars, terms)
      end

      def process_terms(terms)
        return unless terms
        raise ArgumentError, "Unexpected argument (got #{terms.inspect})" \
              unless terms.is_a?(Hash)
        clean_terms    = {}
        missing_fields = []
        terms.each { |f, v| v.nil? ? missing_fields.push({ :missing => f }) : (clean_terms[f] = v) }
        {:terms => clean_terms, :_missing_fields => missing_fields}
      end

    end
  end
end
