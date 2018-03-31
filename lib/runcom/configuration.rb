# frozen_string_literal: true

require "pathname"
require "yaml"
require "refinements/hashes"

module Runcom
  # Default gem configuration with support for custom settings.
  class Configuration
    using Refinements::Hashes

    DEFAULT_FILE_NAME = "configuration.yml"

    def initialize project_name:, file_name: DEFAULT_FILE_NAME, defaults: {}
      @project_name = project_name
      @file_name = file_name
      @defaults = defaults
      @settings = defaults.deep_merge process_settings
    end

    def path
      paths.find(&:exist?)
    end

    def merge custom_settings
      settings.deep_merge custom_settings
    end

    # :reek:FeatureEnvy
    def == other
      other.is_a?(Configuration) && hash == other.hash
    end

    alias eql? ==

    def hash
      [project_name, file_name, to_h, self.class].hash
    end

    def to_h
      settings
    end

    private

    attr_reader :project_name, :file_name, :defaults, :settings

    def process_settings
      load_settings
    rescue Psych::SyntaxError => error
      raise Errors::Syntax, error.message
    rescue StandardError
      defaults
    end

    def load_settings
      yaml = YAML.load_file path
      yaml.is_a?(Hash) ? yaml : {}
    end

    def paths
      XDG::Configuration.computed_dirs.map do |root|
        Pathname "#{root}/#{project_name}/#{file_name}"
      end
    end
  end
end
