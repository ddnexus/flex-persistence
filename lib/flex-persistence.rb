require 'active_attr'
require 'flex/persistence/inspection'
require 'flex/persistence/storage'
require 'flex/persistence/flex_result'
require 'flex/persistence/finders'
require 'flex/class_proxy/stored_model'
require 'flex/instance_proxy/stored_model'
require 'flex/stored_model'

module Flex
  module Persistence
    extend self

    include Loader
    flex.load_search_source  File.expand_path('../flex/persistence_methods.yml', __FILE__)

  end
end
