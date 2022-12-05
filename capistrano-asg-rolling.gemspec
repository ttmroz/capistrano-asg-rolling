# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/asg/rolling/version'

Gem::Specification.new do |spec|
  spec.name          = 'capistrano-asg-rolling'
  spec.version       = Capistrano::ASG::Rolling::VERSION
  spec.authors       = ['Kentaa']
  spec.email         = ['developers@kentaa.nl']

  spec.summary       = 'Capistrano plugin for performing rolling updates to AWS Auto Scaling Groups using Instance Refresh'
  spec.homepage      = 'https://github.com/KentaaNL/capistrano-asg-rolling'
  spec.license       = 'MIT'

  spec.metadata      = { 'rubygems_mfa_required' => 'true' }

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.6.0'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'webmock', '~> 3.11'

  spec.add_dependency 'aws-sdk-autoscaling', '~> 1', '>= 1.67.0'
  spec.add_dependency 'aws-sdk-ec2', '~> 1'
  spec.add_dependency 'capistrano', '~> 3'
  spec.add_dependency 'concurrent-ruby', '~> 1'
end
