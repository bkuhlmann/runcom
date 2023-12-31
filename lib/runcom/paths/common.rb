# frozen_string_literal: true

require "refinements/pathname"

module Runcom
  module Paths
    # Provides common path/functionality for all XDG enhanced objects.
    class Common
      using Refinements::Pathname

      attr_reader :initial

      def initialize initial, context: Context.new
        @initial = Pathname initial
        @context = context
      end

      def namespace = initial.parent

      def file_name = initial.basename

      def active = all.select(&:file?).find(&:exist?)

      def passive = active || global

      def global
        all.tap { |paths| paths.delete local }
           .first
      end

      def local = all.first

      def all = xdg.all.map { |root| root.join initial }

      def to_s = xdg.to_s

      alias to_str to_s

      def inspect = "#<#{self.class}:#{object_id} #{xdg}>"

      private

      attr_reader :context

      def xdg = context.xdg
    end
  end
end
