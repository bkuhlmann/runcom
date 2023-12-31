# frozen_string_literal: true

require "spec_helper"

RSpec.describe Runcom::Config do
  using Refinements::Pathname

  subject(:config) { described_class.new path, context: }

  include_context "with temporary directory"

  let(:path) { Pathname "test/config.yml" }
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
      expect(config.relative).to eq(path)
    end
  end

  describe "#namespace" do
    it "answers namespace" do
      expect(config.namespace).to eq(Pathname("test"))
    end
  end

  describe "#file_name" do
    it "answers file name" do
      expect(config.file_name).to eq(Pathname("config.yml"))
    end
  end

  describe "#active" do
    it "answers config file when path exists" do
      config_path.deep_touch
      expect(config.active).to eq(config_path)
    end
  end

  describe "#passive" do
    it "answers global path when it doesn't exist" do
      expect(config.passive).to eq(temp_dir.join(".config", path))
    end
  end

  describe "#global" do
    it "answers global path" do
      expect(config.global).to eq(temp_dir.join(".config", path))
    end
  end

  describe "#local" do
    it "answers local path" do
      expect(config.local).to eq(Bundler.root.join(".config", path))
    end
  end

  describe "#all" do
    it "answers all paths" do
      expect(config.all).to eq(
        [
          Bundler.root.join(".config/test/config.yml"),
          config_home.join("test", "config.yml"),
          temp_dir.join("one", "test", "config.yml"),
          temp_dir.join("two", "test", "config.yml")
        ]
      )
    end
  end

  shared_examples "a string" do |message|
    it "answers environment settings" do
      expect(config.public_send(message)).to eq(
        "XDG_CONFIG_HOME=#{Bundler.root.join ".config"}:#{config_home} " \
        "XDG_CONFIG_DIRS=#{temp_dir}/one:#{temp_dir}/two"
      )
    end
  end

  describe "#to_s" do
    it_behaves_like "a string", :to_s
  end

  describe "#to_str" do
    it_behaves_like "a string", :to_str
  end

  describe "#inspect" do
    let :pattern do
      %r(
        \A
        \#<
        #{described_class}:\d+\s
        XDG_CONFIG_HOME=#{Bundler.root.join ".config"}:#{config_home}\s
        XDG_CONFIG_DIRS=#{temp_dir}/one:#{temp_dir}/two
        >
        \Z
      )x
    end

    it "answers current environment" do
      expect(config.inspect).to match(pattern)
    end
  end
end
