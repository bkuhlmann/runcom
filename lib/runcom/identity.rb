# frozen_string_literal: true

module Runcom
  # Gem identity information.
  module Identity
    def self.name
      "runcom"
    end

    def self.label
      "Runcom"
    end

    def self.version
      "4.2.1"
    end

    def self.version_label
      "#{label} #{version}"
    end
  end
end
