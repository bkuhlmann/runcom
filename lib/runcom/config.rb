# frozen_string_literal: true

require "pathname"
require "yaml"
require "refinements/hashes"

module Runcom
  # A developer friendly wrapper of XDG config.
  class Config
    using Refinements::Hashes

    DEFAULT_FILE_NAME = "configuration.yml"

    def initialize name, file_name: DEFAULT_FILE_NAME, defaults: {}
      @name = name
      @file_name = file_name
      @defaults = defaults
      @settings = defaults.deep_merge process_settings
    end

    def path
      paths.find(&:exist?)
    end

    def paths
      XDG::Config.new(home: Runcom::Paths::Friendly).all.map do |root|
        Pathname "#{root}/#{name}/#{file_name}"
      end
    end

    def merge other
      self.class.new name, file_name: file_name, defaults: settings.deep_merge(other.to_h)
    end

    # :reek:FeatureEnvy
    def == other
      other.is_a?(Config) && hash == other.hash
    end

    alias eql? ==

    def hash
      [name, file_name, to_h, self.class].hash
    end

    def to_h
      settings
    end

    private

    attr_reader :name, :file_name, :defaults, :settings

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
  end
end
