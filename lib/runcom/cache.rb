# frozen_string_literal: true

module Runcom
  # A developer friendly wrapper of XDG cache.
  Cache = Struct.new :name, :home, :environment, keyword_init: true do
    extend Forwardable

    delegate %i[inspect] => :cache

    def initialize *arguments
      super

      self[:home] ||= Runcom::Paths::Home
      self[:environment] ||= ENV
      @cache = XDG::Cache.new home: home, environment: environment
      freeze
    end

    def path
      paths.find(&:exist?)
    end

    def paths
      cache.all
    end

    private

    attr_reader :cache
  end
end
