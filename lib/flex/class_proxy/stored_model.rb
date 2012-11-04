module Flex
  module ClassProxy
    class StoredModel < Base

      include Modules::Loader
      include Modules::Model
      include Modules::Scope

      alias_method :full_sync, :sync
      def sync(*synced)
        raise ArgumentError, 'You cannot flex.sync(self) a Flex::StoredModel.' \
              if synced.any?{|s| s == host_class}
        full_sync
      end

      def metainfo(vars={})
        { :index => index, :type => type }.merge(vars)
      end

      def initialize(base)
        super
        variables.add metainfo
        @sources   = []
        @templates = {}
        @partials  = {}
      end

      # adds a template instance and defines the template method in the host class
      # returns one or more host_class objects
      def add_template(name, template)
        templates[name] = template
        # no define_singleton_method in 1.8.7
        host_class.instance_eval <<-ruby, __FILE__, __LINE__ + 1
          def #{name}(vars={})
            raise ArgumentError, "#{host_class}.#{name} expects a Hash (got \#{vars.inspect})" unless vars.is_a?(Hash)
            #{host_class.respond_to?(:preprocess_variables) && 'preprocess_variables(vars)'}
            result = flex.templates[:#{name}].render(vars)
            flex.process_result result
          end
        ruby
      end

      def process_result(result)
        case result
        when Flex::Result::SourceDocument
          build_object result
        when Flex::Result::SourceSearch
          result['hits']['hits'].map {|d| build_object(d)}
        else
          result
        end
      end

      def build_object(result)
        object          = host_class.new result['_source']
        object.id       = result['_id']
        object._version = result['_version']
        object
      end

    end
  end
end
