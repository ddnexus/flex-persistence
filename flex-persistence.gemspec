require 'date'

Gem::Specification.new do |s|
  s.name                      = 'flex-persistence'
  s.summary                   = 'Flex Plugin: provides ElasticSearch peristence'
  s.description               = <<-description
Flex Plugin: provides ElasticSearch peristence. It includes: ActiveModel validation and callbacks; ActiveAttr typecasting, attribute defaults.
It implements storage, with optional optimistic lock update, finders, inline scope for easy query definition, etc.
  description
  s.homepage                  = 'http://github.com/ddnexus/flex-persistence'
  s.authors                   = ["Domizio Demichelis"]
  s.email                     = 'dd.nexus@gmail.com'
  s.extra_rdoc_files          = %w[README.md]
  s.files                     = `git ls-files -z`.split("\0")
  s.version                   = File.read(File.expand_path('../VERSION', __FILE__)).strip
  s.date                      = Date.today.to_s
  s.required_rubygems_version = ">= 1.3.6"
  s.rdoc_options              = %w[--charset=UTF-8]

  s.add_runtime_dependency 'flex', '~> 0.5.0'
  s.add_runtime_dependency 'flex-scopes', '~> 0.1.0'
  s.add_runtime_dependency 'active_attr', '~> 0.6.0'
end
