# frozen_string_literal: true

module Runcom
  # A common context for all XDG custom objects.
  Context = Struct.new :home, :environment, :xdg do
    def initialize(**)
      super

      self[:home] ||= Paths::Home
      self[:environment] ||= ENV
      self[:xdg] = xdg.new(home:, environment:) if xdg

      freeze
    end
  end
end
