# frozen_string_literal: true

require "pathname"

module Runcom
  module XDG
    # Represents X Desktop Group (XGD) configuration support. XGD is also known as
    # [Free Desktop](https://www.freedesktop.org). Here is the exact
    # [specification](https://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html) used
    # for this implementation.
    class Configuration
      def self.home_dir
        ENV.fetch "XDG_CONFIG_HOME", File.join(ENV["HOME"], ".config")
      end

      def self.dirs
        ENV.fetch("XDG_CONFIG_DIRS", "/etc/xdg").split ":"
      end

      def self.computed_dirs
        directories = dirs.prepend(home_dir).map { |directory| Pathname(directory).expand_path }
        directories.select(&:exist?)
      end
    end
  end
end
