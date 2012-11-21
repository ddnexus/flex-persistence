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

        extend Persistence::FlexResult
        include ActiveAttr::Model

        extend ActiveModel::Callbacks
        define_model_callbacks :create, :update, :save, :destroy

        refresh = proc{ Flex.refresh_index :index => self.class.flex.index }
        after_save &refresh
        after_destroy &refresh

        include Persistence::Storage::InstanceMethods
        extend Persistence::Storage::ClassMethods
        include Persistence::Inspection
        extend Persistence::Timestamps

        include Finders::Inline
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

  end
end
