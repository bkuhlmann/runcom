# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "runcom"
  spec.version = "9.0.1"
  spec.authors = ["Brooke Kuhlmann"]
  spec.email = ["brooke@alchemists.io"]
  spec.homepage = "https://www.alchemists.io/projects/runcom"
  spec.summary = "An XDG enhanced run command manager for command line interfaces."
  spec.license = "Hippocratic-2.1"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/bkuhlmann/runcom/issues",
    "changelog_uri" => "https://www.alchemists.io/projects/runcom/versions",
    "documentation_uri" => "https://www.alchemists.io/projects/runcom",
    "funding_uri" => "https://github.com/sponsors/bkuhlmann",
    "label" => "Runcom",
    "rubygems_mfa_required" => "true",
    "source_code_uri" => "https://github.com/bkuhlmann/runcom"
  }

  spec.signing_key = Gem.default_key_path
  spec.cert_chain = [Gem.default_cert_path]

  spec.required_ruby_version = "~> 3.2"
  spec.add_dependency "refinements", "~> 10.0"
  spec.add_dependency "xdg", "~> 7.0"
  spec.add_dependency "zeitwerk", "~> 2.6"

  spec.files = Dir["*.gemspec", "lib/**/*"]
  spec.extra_rdoc_files = Dir["README*", "LICENSE*"]
end
