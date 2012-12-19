require 'active_attr'
require 'flex/persistence/timestamps'
require 'flex/persistence/inspection'
require 'flex/persistence/storage'
require 'flex/class_proxy/stored_model'
require 'flex/instance_proxy/stored_model'
require 'flex/stored_model'
require 'flex/result/persistence'

Flex::LIB_PATHS << __FILE__.sub(/flex-persistence.rb$/, '')

# get_docs calls super so we make sure the result is extended by Scope first
Flex::Conf.result_extenders |= [Flex::Result::Scope, Flex::Result::Persistence]
