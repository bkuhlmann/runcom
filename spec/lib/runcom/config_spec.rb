# frozen_string_literal: true

require "spec_helper"

RSpec.describe Runcom::Config, :temp_dir do
  subject(:configuration) { described_class.new name, environment: environment }

  let(:name) { "test" }
  let(:environment) { home.to_env.merge "XDG_CONFIG_HOME" => config_home }
  let(:config_path) { Pathname "#{config_home}/#{name}/configuration.yml" }
  let(:config_home) { Pathname "#{temp_dir}/.config" }
  let(:home) { XDG::Pair.new "HOME", "/home" }

  before { FileUtils.mkdir_p config_path.parent }

  describe "#initialize" do
    let(:config_home) { Pathname "#{Bundler.root}/spec/support" }

    it "raises base error" do
      result = lambda do
        described_class.new "fixtures", environment: environment, file_name: "invalid.yml"
      end

      expect(&result).to raise_error(Runcom::Errors::Syntax)
    end
  end

  describe "#path" do
    it "answers configuration file when path exists" do
      FileUtils.touch config_path
      expect(configuration.path).to eq(config_path)
    end

    it "answers nil when path doesn't exist" do
      expect(configuration.path).to eq(nil)
    end
  end

  describe "#paths" do
    it "answers all path" do
      expect(configuration.paths).to contain_exactly(
        Pathname("#{config_home}/test/configuration.yml"),
        Pathname("/etc/xdg/test/configuration.yml")
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
        custom_configuration = described_class.new name,
                                                   environment: environment,
                                                   defaults: custom_settings

        expect(configuration.merge(custom_settings)).to eq(custom_configuration)
      end

      it "answers new configuration" do
        expect(configuration.merge(custom_settings)).to be_a(described_class)
      end
    end

    context "with custom settings" do
      subject :configuration do
        described_class.new name, environment: environment, defaults: original_settings
      end

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
        modified_configuration = described_class.new name, defaults: modified_settings
        expect(configuration.merge(custom_settings)).to eq(modified_configuration)
      end

      it "answers new configuration" do
        expect(configuration.merge(custom_settings)).to be_a(described_class)
      end
    end
  end

  shared_examples_for "a value object" do
    it "is equal with same instances" do
      expect(configuration).to eq(configuration)
    end

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

  describe "#==" do
    let(:similar) { described_class.new name }
    let(:different) { described_class.new name: "different" }

    it_behaves_like "a value object"
  end

  describe "#eql?" do
    let(:similar) { described_class.new name }
    let(:different) { described_class.new name: "different" }

    it_behaves_like "a value object"
  end

  describe "#equal?" do
    let(:similar) { described_class.new name }
    let(:different) { described_class.new name: "different" }

    it "is equal with same instances" do
      expect(configuration).to equal(configuration)
    end

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
    let(:similar) { described_class.new name }

    it "is equal with same instances" do
      expect(configuration.hash).to eq(configuration.hash)
    end

    it "is equal with similar construction" do
      expect(configuration.hash).to eq(similar.hash)
    end

    it "isn't equal with different project name" do
      different = described_class.new name: "different"
      expect(configuration.hash).not_to eq(different.hash)
    end

    it "isn't equal with different file name" do
      different = described_class.new name, file_name: "different"
      expect(configuration.hash).not_to eq(different.hash)
    end

    it "isn't equal with different defaults" do
      different = described_class.new name, defaults: {test: "example"}
      expect(configuration.hash).not_to eq(different.hash)
    end

    it "isn't equal with different type" do
      expect(configuration.hash).not_to eq("different".hash)
    end
  end

  describe "#to_h" do
    it "answers custom hash when configuration file exists" do
      custom = {remove: {comments: "# encoding: UTF-8"}}
      File.open(config_path, "w") { |file| file << custom.to_yaml }

      expect(configuration.to_h).to eq(custom)
    end

    it "answers default hash when configuration file doesn't exist" do
      expect(configuration.to_h).to eq({})
    end

    context "with configuration file and custom defaults" do
      subject :configuration do
        described_class.new name, environment: environment, defaults: defaults
      end

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
        File.open(config_path, "w") { |file| file << original.to_yaml }
        expect(configuration.to_h).to eq(merged)
      end
    end
  end

  describe "#inspect" do
    it "answers environment settings" do
      expect(configuration.inspect).to eq("XDG_CONFIG_HOME=#{config_home} XDG_CONFIG_DIRS=/etc/xdg")
    end
  end
end
