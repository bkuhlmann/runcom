# frozen_string_literal: true

require "pathname"

module Runcom
  module Paths
    # A collection of XDG directories with a strict adherence to the XDG specification.
    class Directory
      DELIMITER = ":"

      def initialize pair, environment = ENV
        @pair = pair
        @environment = environment
      end

      def default
        String(pair.value).split(DELIMITER).map { |path| Pathname(path).expand_path }
      end

      def dynamic
        environment.fetch(pair.key, String(pair.value)).split(DELIMITER).uniq.map do |path|
          Pathname(path).expand_path
        end
      end

      private

      attr_reader :pair, :environment
    end
  end
end