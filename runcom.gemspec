# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "runcom"
  spec.version = "8.0.1"
  spec.platform = Gem::Platform::RUBY
  spec.authors = ["Brooke Kuhlmann"]
  spec.email = ["brooke@alchemists.io"]
  spec.homepage = "https://www.alchemists.io/projects/runcom"
  spec.summary = "An XDG enhanced run command manager for command line interfaces."
  spec.license = "Hippocratic-3.0"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/bkuhlmann/runcom/issues",
    "changelog_uri" => "https://www.alchemists.io/projects/runcom/versions",
    "documentation_uri" => "https://www.alchemists.io/projects/runcom",
    "label" => "Runcom",
    "rubygems_mfa_required" => "true",
    "source_code_uri" => "https://github.com/bkuhlmann/runcom"
  }

  spec.signing_key = Gem.default_key_path
  spec.cert_chain = [Gem.default_cert_path]

  spec.required_ruby_version = "~> 3.1"
  spec.add_dependency "refinements", "~> 9.1"
  spec.add_dependency "xdg", "~> 6.0"

  spec.files = Dir["*.gemspec", "lib/**/*"]
  spec.extra_rdoc_files = Dir["README*", "LICENSE*"]
  spec.require_paths = ["lib"]
end
