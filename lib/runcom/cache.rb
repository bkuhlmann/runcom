# frozen_string_literal: true

module Runcom
  # A developer friendly wrapper of XDG cache.
  Cache = Struct.new :name, :home, :environment, keyword_init: true do
    def initialize *arguments
      super

      self[:home] ||= Runcom::Paths::Friendly
      self[:environment] ||= ENV
      freeze
    end

    def path
      paths.find(&:exist?)
    end

    def paths
      XDG::Cache.new(home: home, environment: environment).all
    end
  end
end
