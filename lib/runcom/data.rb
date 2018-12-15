# frozen_string_literal: true

require "pathname"

module Runcom
  # A developer friendly wrapper of XDG data.
  Data = Struct.new :name, :home, :environment, keyword_init: true do
    def initialize *arguments
      super

      self[:home] ||= Runcom::Paths::Friendly
      self[:environment] ||= ENV
      freeze
    end

    def path
      paths.find(&:exist?)
    end

    def paths
      XDG::Data.new(home: home, environment: environment).all.map do |root|
        Pathname "#{root}/#{name}"
      end
    end
  end
end
