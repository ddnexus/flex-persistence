module Flex
  module Persistence
    module Finders


      #    MyModel.find(ids)
      #    - ids can ba a single id or an array of ids

      #    MyModel.find '1Momf4s0QViv-yc7wjaDCA'
      #      #=> #<MyModel ... color: "red", size: "small">

      #    MyModel.find ['1Momf4s0QViv-yc7wjaDCA', 'BFdIETdNQv-CuCxG_y2r8g']
      #      #=> [#<MyModel ... color: "red", size: "small">, #<MyModel ... color: "bue", size: "small">]

      def find(ids, vars={})
        result = if ids.is_a?(Array)
                   Flex.multi_get(process_vars(:ids => ids).deep_merge(vars))
                 else
                   Flex.get(process_vars(:id => ids).deep_merge(vars))
                 end
        flex_result(result, vars)
      end


      #    scoped methods. They returns a Scoped object similar to AR.
      #    You can chain scopes, then you can call :count, :first, :all and :scan_all to get your result
      #    This provides an alternative API to the variables hash. See Flex::Persistence::Scoped
      #
      #    scoped = MyModel.terms(:field_one => 'something', :field_two => nil)
      #                    .sort(:field_three => :desc)
      #                    .filters(:range => {:created_at => {:from => 2.days.ago, :to => Time.now})
      #                    .fields('field_one,field_two,field_three') # or [:field_one, :field_two, ...]
      #                    .params(:any => 'param')
      #
      #    # add another filter or other terms at any time
      #    scoped2 = scoped.terms(...).filters(...)
      #
      #    scoped2.count
      #    scoped2.first
      #    scoped2.all
      #    scoped2.scan_all {|batch| do_something_with_results batch}
      #
      delegate :terms, :params, :filters, :sort, :fields, :to => :scoped

      # You can start with a non restricted Flex::Persistence::Scoped object
      def scoped
        Scoped.new(self)
      end

      #    Alternative hash based API
      #    Instead of chaining scopes (terms, sort, ...) and then call the query method (fist, all, scan_all, count)
      #    you can directly pass an hash of variables to the query methods
      #    See Flex::Persistence::Scoped
      #
      #    MyModel.count(vars_or_nil)
      #    MyModel.first(vars_or_nil)
      #    MyModel.all(vars_or_nil)
      #    MyModel.scan_all(vars_or_nil){|batch| do_something_with_results batch}
      #
      [:count, :first, :all, :scan_all].each do |meth|
        define_method(meth) do |vars, &block|
          fields = vars.delete(:fields)
          (vars[:params] ||= {})[:fields] = fields if fields
          terms = Scoped.process_terms(vars.delete(:terms)||{})
          vars  = flex.variables.deep_merge(vars, terms)
          scoped.replace(vars).send(meth, &block)
        end
      end

      def scope(name, scoped=nil, &block)
        proc = case
               when block_given?
                 block
               when scoped.is_a?(Scoped)
                 lambda {scoped}
               when scoped.is_a?(Proc)
                 scoped
               else
                 raise ArgumentError, "Scoped object or Proc expected (got #{scoped.inspect})"
               end
        metaclass = class << self; self end
        metaclass.send(:define_method, name) do |*args|
          scoped = proc.call(*args)
          raise Scope::Error, "The scope :#{name} does not return a Flex::Persistence::Scope" \
                unless scoped.is_a?(Scoped)
          scoped
        end
        scopes << name
      end

    end
  end
end
