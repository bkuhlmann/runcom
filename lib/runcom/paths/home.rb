# frozen_string_literal: true

require "forwardable"
require "pathname"

module Runcom
  module Paths
    # A XDG home path that prefers local over global path.
    class Home
      extend Forwardable

      delegate %i[key value default] => :standard

      def initialize pair, environment = ENV
        @standard = XDG::Paths::Home.new pair, environment
      end

      def dynamic
        String(value).then do |path|
          File.exist?(path) ? Pathname(path).expand_path : standard.dynamic
        end
      end

      def inspect = [standard.key, dynamic].compact.join(XDG::PAIR_DELIMITER)

      private

      attr_reader :standard
    end
  end
end
