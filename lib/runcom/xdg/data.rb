# frozen_string_literal: true

require "forwardable"

module Runcom
  module XDG
    # XDG data that adheres to specification defaults.
    class Data
      extend Forwardable

      HOME_PAIR = Pair.new("XDG_DATA_HOME", ".local/share").freeze
      DIRS_PAIR = Pair.new("XDG_DATA_DIRS", "/usr/local/share:/usr/share").freeze

      delegate %i[home directories all] => :combined

      def initialize home: Paths::Standard, directories: Paths::Directory, environment: ENV
        @combined = Paths::Combined.new home.new(HOME_PAIR, environment),
                                        directories.new(DIRS_PAIR, environment)
      end

      private

      attr_reader :combined
    end
  end
end