# frozen_string_literal: true

require "refinements/hashes"
require "yaml"

module Runcom
  # A developer friendly wrapper of XDG config.
  class Config
    extend Forwardable
    using Refinements::Hashes

    DEFAULT_CONTEXT = Context.new xdg: XDG::Config

    delegate %i[relative namespace file_name current all inspect] => :common

    def initialize path, defaults: {}, context: DEFAULT_CONTEXT
      @common = Paths::Common.new path, context: @context = context
      @settings = defaults.deep_merge process_settings
      freeze
    end

    def merge other
      self.class.new common.relative, defaults: settings.deep_merge(other.to_h), context:
    end

    # :reek:FeatureEnvy
    def ==(other) = other.is_a?(Config) && (hash == other.hash)

    alias eql? ==

    def hash = [common.relative, to_h, self.class].hash

    def to_h = settings

    private

    attr_reader :common, :context, :settings

    def process_settings
      load_settings
    rescue Psych::SyntaxError
      raise Error, "Invalid configuration: #{common.current}."
    rescue StandardError
      context.defaults
      {}
    end

    def load_settings
      yaml = YAML.load_file common.current
      yaml.is_a?(Hash) ? yaml : {}
    end
  end
end
