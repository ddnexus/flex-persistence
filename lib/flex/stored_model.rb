module Flex
  module StoredModel

    attr_reader :_version, :_id
    alias_method :id, :_id

    def self.included(base)
      base.class_eval do
        @flex ||= ClassProxy::StoredModel.new(base)
        def self.flex; @flex end
        extend Persistence::FlexResult
        @flex.variables.deep_merge!(:params => {:version => true})

        @scopes = []
        def self.scopes; @scopes end
        def self.scopes=val; @scopes = val end

        include ActiveAttr::Model

        extend ActiveModel::Callbacks
        define_model_callbacks :create, :update, :save, :destroy

        include Persistence::Storage::InstanceMethods
        extend Persistence::Storage::ClassMethods
        extend Persistence::Finders
        include Persistence::Inspection
        extend Persistence::Timestamps
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
