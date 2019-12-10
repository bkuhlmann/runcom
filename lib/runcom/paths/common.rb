# frozen_string_literal: true

require "forwardable"
require "pathname"

module Runcom
  module Paths
    # Provides common path/functionality for all XDG enhanced objects.
    class Common
      extend Forwardable

      delegate %i[inspect] => :xdg

      attr_reader :relative

      def initialize relative, context: Context.new
        @relative = Pathname relative
        @context = context
      end

      def namespace
        relative.parent
      end

      def file_name
        relative.basename
      end

      def current
        all.find(&:exist?)
      end

      def all
        xdg.all.map { |root| root.join relative }
      end

      private

      attr_reader :context

      def xdg
        context.xdg
      end
    end
  end
end
