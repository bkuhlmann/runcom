# frozen_string_literal: true

require "pathname"

module Runcom
  # A developer friendly wrapper of XDG data.
  Data = Struct.new :name, :home, :environment, keyword_init: true do
    extend Forwardable

    delegate %i[inspect] => :data

    def initialize *arguments
      super

      self[:home] ||= Runcom::Paths::Home
      self[:environment] ||= ENV
      @data = XDG::Data.new home: home, environment: environment
      freeze
    end

    def path
      paths.find(&:exist?)
    end

    def paths
      data.all.map { |root| Pathname "#{root}/#{name}" }
    end

    private

    attr_reader :data
  end
end
