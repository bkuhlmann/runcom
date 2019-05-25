# frozen_string_literal: true

require "forwardable"

module Runcom
  module Paths
    # A XDG home path with a loose adherence to XDG specification by preferring local path if it
    # exists, otherwise defaulting to standard computed path.
    class Friendly
      extend Forwardable

      delegate %i[key value default] => :standard

      def initialize pair, environment = ENV
        @standard = XDG::Paths::Standard.new pair, environment
      end

      def dynamic
        String(value).then do |path|
          File.exist?(path) ? Pathname(path).expand_path : standard.dynamic
        end
      end

      private

      attr_reader :standard
    end
  end
end
