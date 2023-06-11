# frozen_string_literal: true

require "spec_helper"

RSpec.describe Runcom::Config do
  using Refinements::Pathnames

  subject(:configuration) { described_class.new path, context: }

  include_context "with temporary directory"

  let(:path) { Pathname "test/configuration.yml" }
  let(:config_path) { config_home.join path }
  let(:config_home) { temp_dir.join ".config" }

  let :environment do
    {
      "HOME" => "/home",
      "XDG_CONFIG_HOME" => config_home,
      "XDG_CONFIG_DIRS" => "#{temp_dir}/one:#{temp_dir}/two"
    }
  end

  let(:context) { Runcom::Context.new xdg: XDG::Config, environment: }

  describe "#relative" do
    it "answers relative path" do
      expect(configuration.relative).to eq(path)
    end
  end

  describe "#namespace" do
    it "answers namespace" do
      expect(configuration.namespace).to eq(Pathname("test"))
    end
  end

  describe "#file_name" do
    it "answers file name" do
      expect(configuration.file_name).to eq(Pathname("configuration.yml"))
    end
  end

  describe "#active" do
    it "answers configuration file when path exists" do
      config_path.deep_touch
      expect(configuration.active).to eq(config_path)
    end
  end

  describe "#all" do
    it "answers all paths" do
      expect(configuration.all).to eq(
        [
          Bundler.root.join(".config/test/configuration.yml"),
          config_home.join("test", "configuration.yml"),
          temp_dir.join("one", "test", "configuration.yml"),
          temp_dir.join("two", "test", "configuration.yml")
        ]
      )
    end
  end

  describe "#inspect" do
    it "answers environment settings" do
      expect(configuration.inspect).to eq(
        %(XDG_CONFIG_HOME=#{Bundler.root.join ".config"}:#{config_home} ) \
        "XDG_CONFIG_DIRS=#{temp_dir}/one:#{temp_dir}/two"
      )
    end
  end
end
