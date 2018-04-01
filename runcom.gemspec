# frozen_string_literal: true

$LOAD_PATH.append File.expand_path("lib", __dir__)
require "runcom/identity"

Gem::Specification.new do |spec|
  spec.name = Runcom::Identity.name
  spec.version = Runcom::Identity.version
  spec.platform = Gem::Platform::RUBY
  spec.authors = ["Brooke Kuhlmann"]
  spec.email = ["brooke@alchemists.io"]
  spec.homepage = "https://github.com/bkuhlmann/runcom"
  spec.summary = "A run command manager for command line interfaces."
  spec.license = "Apache-2.0"

  spec.metadata = {
    "source_code_uri" => "https://github.com/bkuhlmann/runcom",
    "changelog_uri" => "https://github.com/bkuhlmann/runcom/blob/master/CHANGES.md",
    "bug_tracker_uri" => "https://github.com/bkuhlmann/runcom/issues"
  }

  spec.signing_key = Gem.default_key_path
  spec.cert_chain = [Gem.default_cert_path]

  spec.required_ruby_version = "~> 2.5"
  spec.add_dependency "refinements", "~> 5.1"
  spec.add_development_dependency "bundler-audit", "~> 0.6"
  spec.add_development_dependency "climate_control", "~> 0.1"
  spec.add_development_dependency "codeclimate-test-reporter", "~> 1.0"
  spec.add_development_dependency "gemsmith", "~> 12.0"
  spec.add_development_dependency "git-cop", "~> 2.2"
  spec.add_development_dependency "guard-rspec", "~> 4.7"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "pry-byebug", "~> 3.5"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "reek", "~> 4.8"
  spec.add_development_dependency "rspec", "~> 3.7"
  spec.add_development_dependency "rubocop", "~> 0.54"

  spec.files = Dir["lib/**/*"]
  spec.extra_rdoc_files = Dir["README*", "LICENSE*"]
  spec.require_paths = ["lib"]
end
