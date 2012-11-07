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
                   Flex.multi_get(metainfo(:ids => ids).deep_merge(vars))
                 else
                   Flex.get(metainfo(:id => ids).deep_merge(vars))
                 end
        flex_result(result)
      end

      #    MyModel.first(terms=nil, vars={})
      #    - terms will narrow the search and accepts :any_term => nil for missing values
      #    - vars are the standard rendering vars (you can pass parameters, etc.)
      #
      #    MyModel.first
      #      #=> #<MyModel ... color: nil, size: "small">
      #
      #    MyModel.first(:color => nil, :size => 'small')
      #      #=> #<MyModel ... color: nil, size: "small">
      #
      #    MyModel.first(:color => 'blue', :size => 'small')
      #      #=> #<MyModel ... color: "blue", size: "small">
      #
      def first(terms=nil, vars={})
        vars = Variables.new(:params => {:size => 1}).deep_merge(vars)
        do_find(terms, vars).first
      end

      #    MyModel.all(terms=nil, vars={}, &block)
      #    - terms will narrow the search and accepts :any_term => nil for missing values
      #    - vars are the standard rendering vars (you can pass parameters, etc.)
      #    - the results will be limited with the default :size param, if you need to retrieve all, pass a block
      #    - if you pass a block, a scan_search will be performed, and your block will be yielded many times
      #      with an array of batched results. You can pass :scroll and :size as :params in order to control the action.
      #      See http://www.elasticsearch.org/guide/reference/api/search/scroll.html
      #
      #    MyModel.all(terms_or_nil)
      #      #=> [#<MyModel ... color: nil, size: "small">, #<MyModel ... color: "red", size: "small">, ... limited to :size]
      #
      #    MyModel.all(terms_or_nil) do |batch_of_results|
      #      do_something_with batch_of_results
      #    end
      #
      #    MyModel.all(:color => nil, :size => 'small')
      #      #=> [#<MyModel ... color: nil, size: "small">, #<MyModel ... color: nil, size: "small">]
      #
      #    MyModel.all(:color => 'blue', :size => 'small')
      #      #=> [#<MyModel ... color: "blue", size: "small">]
      #
      def all(terms=nil, vars={}, &block)
        do_find(terms, vars, &block)
      end

      def count(terms=nil, vars={})
        case terms
        when nil
          Flex.count(metainfo(vars))['count']
        when Hash
          hash = process_terms(terms, vars)
          Persistence.flex.count_search(:find_by_terms, hash)['hits']['total']
        else
          raise ArgumentError, "Unexpected argument (got #{terms.inspect})"
        end
      end

      # 2 queries needed
      def last
        result = Flex.match_all metainfo(:params => {:size => 1, :from => count-1})
        flex_result(result).first
      end

    private

      def metainfo(vars={})
        flex.variables.deep_merge(vars)
      end

      def do_find(terms, vars={}, &block)
        result = case terms
                 when nil
                   if block_given?
                     flex.scan_search(Flex.flex.templates[:match_all], metainfo(vars), &block)
                   else
                     Flex.match_all metainfo(vars)
                   end
                 when Hash
                   hash = process_terms(terms, vars)
                   if block_given?
                     flex.scan_search(Persistence.flex.templates[:find_by_terms], hash, &block)
                   else
                     Persistence.find_by_terms hash
                   end
                 else
                   raise ArgumentError, "Unexpected argument (got #{terms.inspect})"
                 end
        flex_result(result)
      end

      def process_terms(terms, vars)
        clean_terms    = {}
        missing_fields = []
        terms.each { |f, v| v.nil? ? missing_fields.push({ :missing => f }) : (clean_terms[f] = v) }
        metainfo(:terms => clean_terms, :_missing_fields => missing_fields).merge(vars)
      end

    end
  end
end
