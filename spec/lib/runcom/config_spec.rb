# frozen_string_literal: true

require "spec_helper"

RSpec.describe Runcom::Config do
  using Refinements::Pathnames

  subject(:configuration) { described_class.new path, defaults: defaults, context: context }

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

  let(:defaults) { {} }
  let(:context) { Runcom::Context.new xdg: XDG::Config, environment: environment }

  before { config_path.parent.make_path }

  describe "#initialize" do
    let(:config_home) { Bundler.root.join "spec", "support" }

    it "raises base error" do
      result = -> { described_class.new Pathname("fixtures/invalid.yml"), context: context }
      expect(&result).to raise_error(Runcom::Errors::Syntax)
    end
  end

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

  describe "#current" do
    it "answers configuration file when path exists" do
      config_path.make_path
      expect(configuration.current).to eq(config_path)
    end
  end

  describe "#all" do
    it "answers all paths" do
      expect(configuration.all).to contain_exactly(
        config_home.join("test", "configuration.yml"),
        temp_dir.join("one", "test", "configuration.yml"),
        temp_dir.join("two", "test", "configuration.yml")
      )
    end
  end

  describe "#merge" do
    context "with default settings" do
      let :custom_settings do
        {
          add: {
            comments: "encoding: UTF-8",
            includes: [".gemspec"]
          }
        }
      end

      let :merged_settings do
        {
          add: {
            comments: "encoding: UTF-8",
            includes: [".gemspec"]
          }
        }
      end

      it "merges custom settings" do
        expect(configuration.merge(custom_settings).to_h).to eq(merged_settings)
      end

      it "merges custom configuration" do
        custom_configuration = described_class.new path, defaults: custom_settings, context: context
        expect(configuration.merge(custom_settings)).to eq(custom_configuration)
      end

      it "answers new configuration" do
        expect(configuration.merge(custom_settings)).to be_a(described_class)
      end
    end

    context "with custom settings" do
      let(:defaults) { original_settings }

      let :original_settings do
        {
          add: {
            comments: "",
            includes: []
          },
          remove: {
            comments: "",
            includes: []
          }
        }
      end

      let :custom_settings do
        {
          add: {
            includes: [".gemspec"]
          },
          remove: {
            comments: "# encoding: UTF-8"
          }
        }
      end

      let :modified_settings do
        {
          add: {
            comments: "",
            includes: [".gemspec"]
          },
          remove: {
            comments: "# encoding: UTF-8",
            includes: []
          }
        }
      end

      it "merges custom settings" do
        expect(configuration.merge(custom_settings).to_h).to eq(modified_settings)
      end

      it "merges custom configuration" do
        expect(configuration.merge(custom_settings)).to eq(
          described_class.new(path, defaults: modified_settings, context: context)
        )
      end

      it "answers new configuration" do
        expect(configuration.merge(custom_settings)).to be_a(described_class)
      end
    end
  end

  describe "#==" do
    let(:similar) { described_class.new path }
    let(:different) { described_class.new "different" }

    it "is equal with similar construction" do
      expect(configuration).to eq(similar)
    end

    it "isn't equal with different values" do
      expect(configuration).not_to eq(different)
    end

    it "isn't equal with different type" do
      expect(configuration).not_to eq("different")
    end
  end

  describe "#eql?" do
    let(:similar) { described_class.new path }
    let(:different) { described_class.new "different" }

    it "is equal with similar construction" do
      expect(configuration).to eql(similar)
    end

    it "isn't equal with different values" do
      expect(configuration).not_to eql(different)
    end

    it "isn't equal with different type" do
      expect(configuration).not_to eql("different")
    end
  end

  describe "#equal?" do
    let(:similar) { described_class.new path }
    let(:different) { described_class.new "different" }

    it "isn't equal with similar construction" do
      expect(configuration).not_to equal(similar)
    end

    it "isn't equal with different values" do
      expect(configuration).not_to equal(different)
    end

    it "isn't equal with different type" do
      expect(configuration).not_to equal("different")
    end
  end

  describe "#hash" do
    let(:similar) { described_class.new path }

    it "is equal with similar construction" do
      expect(configuration.hash).to eq(similar.hash)
    end

    it "isn't equal with different namespace" do
      different = described_class.new "different"
      expect(configuration.hash).not_to eq(different.hash)
    end

    it "isn't equal with different file name" do
      different = described_class.new Pathname("different")
      expect(configuration.hash).not_to eq(different.hash)
    end

    it "isn't equal with different defaults" do
      different = described_class.new path, defaults: {a: 1}
      expect(configuration.hash).not_to eq(different.hash)
    end

    it "isn't equal with different type" do
      expect(configuration.hash).not_to eq("different".hash)
    end
  end

  describe "#to_h" do
    it "answers custom hash when configuration file exists" do
      custom = {remove: {comments: "# encoding: UTF-8"}}
      config_path.write custom.to_yaml

      expect(configuration.to_h).to eq(custom)
    end

    it "answers default hash when configuration file doesn't exist" do
      expect(configuration.to_h).to eq({})
    end

    context "with configuration file and custom defaults" do
      let :original do
        {
          remove: {
            comments: "# encoding: UTF-8"
          }
        }
      end

      let :defaults do
        {
          remove: {
            comments: "# frozen_string_literal: true",
            includes: []
          }
        }
      end

      let :merged do
        {
          remove: {
            comments: "# encoding: UTF-8",
            includes: []
          }
        }
      end

      it "answers merged hash" do
        config_path.write original.to_yaml
        expect(configuration.to_h).to eq(merged)
      end
    end
  end

  describe "#inspect" do
    it "answers environment settings" do
      expect(configuration.inspect).to eq(
        "XDG_CONFIG_HOME=#{config_home} XDG_CONFIG_DIRS=#{temp_dir}/one:#{temp_dir}/two"
      )
    end
  end
end
