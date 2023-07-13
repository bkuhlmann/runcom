# frozen_string_literal: true

require "forwardable"

module Runcom
  # A developer friendly wrapper of XDG cache.
  class Cache
    extend Forwardable

    CONTEXT = Context.new xdg: XDG::Cache

    delegate %i[relative namespace file_name active passive global local all inspect] => :common

    def initialize path, context: CONTEXT
      @common = Paths::Common.new path, context:
    end

    private

    attr_reader :common
  end
end
