# frozen_string_literal: true

require "spec_helper"

RSpec.describe Runcom::XDG::Environment do
  subject(:environment) { described_class.new environment: {"HOME" => "/home"} }

  describe "#cache_home" do
    it "answers cache home" do
      expect(environment.cache_home).to eq(Pathname("/home/.cache"))
    end
  end

  describe "config_home" do
    it "answers config home" do
      expect(environment.config_home).to eq(Pathname("/home/.config"))
    end
  end

  describe "config_dirs" do
    it "answers config dirs" do
      expect(environment.config_dirs).to contain_exactly(Pathname("/etc/xdg"))
    end
  end

  describe "data_home" do
    it "answers data home" do
      expect(environment.data_home).to eq(Pathname("/home/.local/share"))
    end
  end

  describe "data_dirs" do
    it "answers data dirs" do
      expect(environment.data_dirs).to contain_exactly(
        Pathname("/usr/local/share"),
        Pathname("/usr/share")
      )
    end
  end
end
