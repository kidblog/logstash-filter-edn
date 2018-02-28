Gem::Specification.new do |s|
  s.name          = 'logstash-filter-edn'
  s.version       = '0.1.0'
  s.licenses      = ['Apache-2.0']
  s.summary       = 'A Logstash filter for EDN data.'
  s.homepage      = "https://gitlab.kidblog.org/evan/logstash-filter-edn"
  s.authors       = ['Evan Niessen-Derry']
  s.email         = 'eniessenderry@gmail.com'
  s.require_paths = ['lib']

  # Files
  s.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE','NOTICE.TXT']
   # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "filter" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core-plugin-api", "~> 2.1"
  s.add_development_dependency 'logstash-devutils', "~> 1.3"
  #s.add_development_dependency 'pry-byebug', '~>3.6'
  #s.add_development_dependency 'pry-debugger', '~>0.2'
  s.add_development_dependency 'ruby-debug', '~> 0.10'

  # Our particular dependencies
  s.add_runtime_dependency 'edn', "~> 1.1"
end
