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
        String(value).then { |path| Pathname path }
                     .then { |path| [path.expand_path, standard.dynamic] }
      end

      def to_s
        [standard.key, dynamic.join(XDG::Paths::Directory::DELIMITER)].compact.join XDG::DELIMITER
      end

      alias to_str to_s

      def inspect = to_s

      private

      attr_reader :standard
    end
  end
end
