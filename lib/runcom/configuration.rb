# frozen_string_literal: true

require "refinements/hashes"

module Runcom
  # Default gem configuration with support for custom settings.
  class Configuration
    using Refinements::Hashes

    def initialize file_name:, defaults: {}
      @file_name = file_name
      @defaults = defaults
      @settings = defaults.deep_merge load_settings
    end

    def local?
      File.exist? local_path
    end

    def global?
      File.exist? global_path
    end

    def local_path
      File.join Dir.pwd, file_name
    end

    def global_path
      File.join ENV["HOME"], file_name
    end

    def computed_path
      local? ? local_path : global_path
    end

    def merge custom_settings
      settings.deep_merge custom_settings
    end

    def to_h
      settings
    end

    private

    attr_reader :file_name, :defaults, :settings

    def load_settings
      yaml = YAML.load_file computed_path
      yaml.is_a?(Hash) ? yaml : {}
    rescue
      defaults
    end
  end
end
