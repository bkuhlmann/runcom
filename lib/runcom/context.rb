# frozen_string_literal: true

module Runcom
  # A common context for all XDG custom objects.
  Context = Struct.new :defaults, :home, :environment, :xdg, keyword_init: true do
    def initialize *arguments
      super

      self[:home] ||= Paths::Home
      self[:environment] ||= ENV
      self[:xdg] = xdg.new(home:, environment:) if xdg
    end
  end
end
