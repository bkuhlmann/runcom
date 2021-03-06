# frozen_string_literal: true

require "forwardable"

module Runcom
  # A developer friendly wrapper of XDG cache.
  class Cache
    extend Forwardable

    DEFAULT_CONTEXT = Context.new xdg: XDG::Cache

    delegate %i[relative namespace file_name current all inspect] => :common

    def initialize path, context: DEFAULT_CONTEXT
      @common = Paths::Common.new path, context: context
    end

    private

    attr_reader :common
  end
end
