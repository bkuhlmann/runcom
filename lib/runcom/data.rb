# frozen_string_literal: true

require "forwardable"

module Runcom
  # A developer friendly wrapper of XDG data.
  class Data
    extend Forwardable

    CONTEXT = Context.new xdg: XDG::Data

    delegate %i[relative namespace file_name current all inspect] => :common

    def initialize path, context: CONTEXT
      @common = Paths::Common.new path, context:
    end

    private

    attr_reader :common
  end
end
