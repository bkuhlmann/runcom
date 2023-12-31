# frozen_string_literal: true

module Runcom
  # A common context for all XDG custom objects.
  Context = ::Data.define :home, :environment, :xdg do
    def initialize home: Paths::Home, environment: ENV, xdg: nil
      computed_xdg = xdg.is_a?(Class) ? xdg.new(home:, environment:) : xdg
      super home:, environment:, xdg: computed_xdg
    end
  end
end
