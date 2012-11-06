module Flex
  module StoredModel

    attr_accessor :_version, :_id
    alias_method :id, :_id

    def self.included(base)
      base.class_eval do
        @flex ||= ClassProxy::StoredModel.new(base)
        def self.flex; @flex end
        extend Persistence::Result

        include ActiveAttr::Model

        extend ActiveModel::Callbacks
        define_model_callbacks :save, :destroy

        include Persistence::Storage::InstanceMethods
        extend Persistence::Storage::ClassMethods
        extend Persistence::Find
        include Persistence::Inspection

        class << self
          delegate :scope, :scroll_search, :to => :flex
        end
      end
    end

    def flex
      @flex ||= InstanceProxy::StoredModel.new(self)
    end

    def flex_source
      attributes.to_json
    end

    def flex_indexable?
      true
    end

    def update_attributes(attributes)
      attributes.each {|name, value| send "#{name}=", value }
    end

  end
end
