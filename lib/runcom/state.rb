# frozen_string_literal: true

require "forwardable"

module Runcom
  # A developer friendly wrapper of XDG state.
  class State
    extend Forwardable

    CONTEXT = Context.new xdg: XDG::State

    delegate %i[initial namespace file_name active passive global local all to_s to_str] => :common

    def initialize path, context: CONTEXT
      @common = Paths::Common.new(path, context:)
      freeze
    end

    def inspect = "#<#{self.class}:#{object_id} #{common}>"

    private

    attr_reader :common
  end
end
