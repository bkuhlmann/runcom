# frozen_string_literal: true

module Runcom
  module XDG
    # A XDG environment that provides access to all variables.
    class Environment
      def initialize home: Paths::Standard, directories: Paths::Directory, environment: ENV
        @cache = Cache.new home: home, directories: directories, environment: environment
        @config = Config.new home: home, directories: directories, environment: environment
        @data = Data.new home: home, directories: directories, environment: environment
      end

      def cache_home
        cache.home
      end

      def config_home
        config.home
      end

      def config_dirs
        config.directories
      end

      def data_home
        data.home
      end

      def data_dirs
        data.directories
      end

      private

      attr_reader :cache, :config, :data
    end
  end
end
