module Flex
  module StoredModel

    attr_reader :_version, :_id
    alias_method :id, :_id

    def self.included(base)
      base.class_eval do
        @flex ||= ClassProxy::Base.new(base)
        @flex.extend(ClassProxy::Model).init
        @flex.extend(ClassProxy::StoredModel).init :params => {:version => true}
        def self.flex; @flex end

        include Scopes
        include ActiveAttr::Model

        extend  ActiveModel::Callbacks
        define_model_callbacks :create, :update, :save, :destroy

        include Persistence::Storage::InstanceMethods
        extend  Persistence::Storage::ClassMethods
        include Persistence::Inspection
        extend  Persistence::Timestamps
      end
    end

    def flex
      @flex ||= InstanceProxy::StoredModel.new(self)
    end

    def flex_source
      attributes
    end

    def flex_indexable?
      true
    end

  end
end
