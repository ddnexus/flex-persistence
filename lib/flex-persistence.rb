require 'active_attr'
require 'flex/persistence/timestamps'
require 'flex/persistence/inspection'
require 'flex/persistence/storage'
require 'flex/persistence/flex_result'
require 'flex/class_proxy/stored_model'
require 'flex/instance_proxy/stored_model'
require 'flex/stored_model'

Flex::LIB_PATHS << __FILE__.sub(/flex-persistence.rb$/, '')
