# frozen_string_literal: true

require "pathname"
require "yaml"
require "refinements/hashes"

module Runcom
  # Default gem configuration with support for custom settings.
  class Configuration
    using Refinements::Hashes

    attr_reader :path

    def initialize project_name:, file_name: "configuration.yml", defaults: {}
      @path = Pathname "#{XDG::Configuration.computed_dir}/#{project_name}/#{file_name}"
      @defaults = defaults
      @settings = defaults.deep_merge load_settings
    end

    def merge custom_settings
      settings.deep_merge custom_settings
    end

    def to_h
      settings
    end

    private

    attr_reader :file_path, :defaults, :settings

    def load_settings
      yaml = YAML.load_file path
      yaml.is_a?(Hash) ? yaml : {}
    rescue
      defaults
    end
  end
end
