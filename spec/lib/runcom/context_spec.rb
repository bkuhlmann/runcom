# frozen_string_literal: true

require "spec_helper"

RSpec.describe Runcom::Context do
  describe "#initialize" do
    it "answers default context" do
      expect(described_class.new).to have_attributes(
        home: Runcom::Paths::Home,
        environment: ENV,
        xdg: nil
      )
    end

    it "answers custom context XDG class" do
      context = described_class.new home: XDG::Paths::Home, environment: {b: 2}, xdg: XDG::Config

      expect(context).to have_attributes(
        home: XDG::Paths::Home,
        environment: {b: 2},
        xdg: XDG::Config
      )
    end

    it "answers custom context XDG instance" do
      xdg = XDG::Config.new
      context = described_class.new(home: XDG::Paths::Home, environment: {b: 2}, xdg:)

      expect(context).to have_attributes(home: XDG::Paths::Home, environment: {b: 2}, xdg:)
    end

    it "answers frozen instance" do
      expect(described_class.new.frozen?).to be(true)
    end
  end
end
