# frozen_string_literal: true

require "forwardable"
require "refinements/pathname"

module Runcom
  module Paths
    # Provides common path/functionality for all XDG enhanced objects.
    class Common
      extend Forwardable

      using Refinements::Pathname

      delegate %i[inspect] => :xdg

      attr_reader :relative

      def initialize relative, context: Context.new
        @relative = Pathname relative
        @context = context
      end

      def namespace = relative.parent

      def file_name = relative.basename

      def active = all.select(&:file?).find(&:exist?)

      def passive = active || global

      def global
        all.tap { |paths| paths.delete local }
           .first
      end

      def local = all.first

      def all = xdg.all.map { |root| root.join relative }

      def to_s = xdg.to_s

      alias to_str to_s

      private

      attr_reader :context

      def xdg = context.xdg
    end
  end
end
