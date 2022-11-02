require_relative 'lib/nexl_shared/version'

Gem::Specification.new do |spec|
  spec.name          = "nexl_shared"
  spec.version       = NexlShared::VERSION
  spec.authors       = ["grant"]
  spec.email         = ["grant@nexl.io"]

  spec.summary       = "Shared code between different NEXL rails engines and projects"
  spec.description   = "Shared code between different NEXL rails engines and projects"
  spec.homepage      = "https://bitbucket.org/nexl-lts/nexl/src/master/local_gems/nexl_shared"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.1.0")

  spec.metadata["homepage_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir["#{__dir__}/**"].reject { |f| f.match(%r{^(coverage|spec|vendor)/}) }

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'actionpack', '>= 6.0', '< 8.0'
  spec.add_dependency 'activejob', '>= 6.0', '< 8.0'
  spec.add_dependency 'activerecord', '>= 6.0', '< 8.0'
  spec.add_dependency 'activesupport', '>= 6.0', '< 8.0'
  spec.add_dependency 'graphql', '>= 1.9.4'
  spec.add_dependency 'rack-timeout', '>= 0.6.0'
  spec.add_dependency 'rollbar', '>= 2.18.2'
  spec.metadata = {
    'rubygems_mfa_required' => 'true'
  }
end
