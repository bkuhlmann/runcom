# frozen_string_literal: true

module Runcom
  module Errors
    # The error class for YAML-related exceptions.
    class Syntax < Base
      def message = "Invalid configuration #{super}."
    end
  end
end
