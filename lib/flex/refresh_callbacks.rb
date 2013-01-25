module Flex
  module RefreshCallbacks

    class MissingStoredModelError < StandardError; end

    def self.included(base)
      raise MissingStoredModelError, 'Flex::RefreshCallbacks can only be included in a Flex::StoredModel model class' \
            unless base.include? Flex::StoredModel
      base.class_eval do
        refresh = proc{ Flex.refresh_index :index => self.class.flex.index }
        after_create  &refresh
        after_update  &refresh
        after_destroy &refresh
      end
    end

  end
end
