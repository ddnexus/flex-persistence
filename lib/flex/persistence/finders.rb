module Flex
  module Persistence
    module Find


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
                   Flex.multi_get(metainfo(:ids => ids).add(vars))
                 else
                   Flex.get(metainfo(:id => ids).add(vars))
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
        vars = Variables.new(:params => {:size => 1}).add(vars)
        do_find(terms, vars).first
      end

      #    MyModel.all(terms=nil, vars={}, &block)
      #    - terms will narrow the search and accepts :any_term => nil for missing values
      #    - vars are the standard rendering vars (you can pass parameters, etc.)
      #    - the results will be limited with the default :size param, if you need to retrieve all, pass a block
      #    - if you pass a block, a scroll_search will be performed, and your block will be yielded many times
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

      # needs a proper implementation with conditions
      def count
        result = Flex.count metainfo
        result['count']
      end

      # 2 queries needed
      def last
        result = Flex.match_all metainfo(:params => {:size => 1, :from => count-1})
        flex_result(result).first
      end

    private

      def metainfo(vars={})
        flex.variables.add(vars)
      end

      def do_find(terms, vars={}, &block)
        result = case terms
                 when nil
                   if block_given?
                     flex.scroll_search(Flex.flex.templates[:match_all], metainfo(vars), &block)
                   else
                     Flex.match_all metainfo(vars)
                   end
                 when Hash
                   clean_terms    = {}
                   missing_fields = []
                   terms.each {|f, v| v.nil? ? missing_fields.push({ :missing => f }) : clean_terms[f] = v }
                   hash = metainfo(:terms => clean_terms, :_missing_field => missing_fields).merge(vars)
                   if block_given?
                     flex.scroll_search(Persistence.flex.templates[:find_by_terms], hash, &block)
                   else
                     Persistence.find_by_terms hash
                   end
                 else
                   raise ArgumentError, "Unexpected argument (got #{terms.inspect})"
                 end
        flex_result(result)
      end


    end
  end
end
