# frozen_string_literal: true

require "pathname"
require "yaml"
require "refinements/hashes"

# :reek:TooManyInstanceVariables
module Runcom
  # A developer friendly wrapper of XDG config.
  class Config
    extend Forwardable
    using Refinements::Hashes

    DEFAULT_FILE_NAME = "configuration.yml"

    delegate %i[inspect] => :config

    # rubocop:disable Metrics/ParameterLists
    def initialize name, environment: ENV, file_name: DEFAULT_FILE_NAME, defaults: {}
      @name = name
      @environment = environment
      @file_name = file_name
      @defaults = defaults
      @config = XDG::Config.new home: Runcom::Paths::Friendly, environment: environment
      @settings = defaults.deep_merge process_settings
      freeze
    end
    # rubocop:enable Metrics/ParameterLists

    def path
      paths.find(&:exist?)
    end

    def paths
      config.all.map { |root| Pathname "#{root}/#{name}/#{file_name}" }
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

    attr_reader :name, :environment, :file_name, :defaults, :settings, :config

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
