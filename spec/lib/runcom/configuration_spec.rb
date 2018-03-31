# frozen_string_literal: true

require "spec_helper"

RSpec.describe Runcom::Configuration, :temp_dir do
  let(:name) { "test" }
  let(:xdg_dir) { Pathname "#{temp_dir}/.config" }
  let(:config_dir) { Pathname "#{xdg_dir}/#{name}" }
  let(:config_path) { Pathname "#{config_dir}/configuration.yml" }
  subject { described_class.new name }
  before { FileUtils.mkdir_p config_dir }

  describe "#initialize" do
    let(:xdg_dir) { Pathname "#{Bundler.root}/spec/support" }

    it "raises base error" do
      ClimateControl.modify XDG_CONFIG_HOME: xdg_dir.to_s do
        result = -> { described_class.new "fixtures", file_name: "invalid.yml" }
        expect(&result).to raise_error(Runcom::Errors::Syntax)
      end
    end
  end

  describe "#path" do
    it "answers configuration file when path exists" do
      FileUtils.touch config_path
      ClimateControl.modify XDG_CONFIG_HOME: xdg_dir.to_s do
        expect(subject.path).to eq(config_path)
      end
    end

    it "answers nil when path doesn't exist" do
      ClimateControl.modify XDG_CONFIG_HOME: xdg_dir.to_s do
        expect(subject.path).to eq(nil)
      end
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
        ClimateControl.modify XDG_CONFIG_HOME: xdg_dir.to_s do
          expect(subject.merge(custom_settings)).to eq(merged_settings)
        end
      end
    end

    context "with custom settings" do
      let :default_settings do
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

      subject { described_class.new name, defaults: default_settings }

      it "merges custom settings" do
        modified_settings = {
          add: {
            comments: "",
            includes: [".gemspec"]
          },
          remove: {
            comments: "# encoding: UTF-8",
            includes: []
          }
        }

        ClimateControl.modify XDG_CONFIG_HOME: xdg_dir.to_s do
          expect(subject.merge(custom_settings)).to eq(modified_settings)
        end
      end
    end
  end

  shared_examples_for "a value object" do
    it "is equal with same instances" do
      expect(subject).to eq(subject)
    end

    it "is equal with similar construction" do
      expect(subject).to eq(similar)
    end

    it "isn't equal with different values" do
      expect(subject).to_not eq(different)
    end

    it "isn't equal with different type" do
      expect(subject).to_not eq("different")
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
      expect(subject).to equal(subject)
    end

    it "isn't equal with similar construction" do
      expect(subject).to_not equal(similar)
    end

    it "isn't equal with different values" do
      expect(subject).to_not equal(different)
    end

    it "isn't equal with different type" do
      expect(subject).to_not equal("different")
    end
  end

  describe "#hash" do
    let(:similar) { described_class.new name }

    it "is equal with same instances" do
      expect(subject.hash).to eq(subject.hash)
    end

    it "is equal with similar construction" do
      expect(subject.hash).to eq(similar.hash)
    end

    it "isn't equal with different project name" do
      different = described_class.new name: "different"
      expect(subject.hash).to_not eq(different.hash)
    end

    it "isn't equal with different file name" do
      different = described_class.new name, file_name: "different"
      expect(subject.hash).to_not eq(different.hash)
    end

    it "isn't equal with different defaults" do
      different = described_class.new name, defaults: {test: "example"}
      expect(subject.hash).to_not eq(different.hash)
    end

    it "isn't equal with different type" do
      expect(subject.hash).to_not eq("different".hash)
    end
  end

  describe "#to_h" do
    it "answers custom hash when configuration file exists" do
      custom = {remove: {comments: "# encoding: UTF-8"}}

      ClimateControl.modify XDG_CONFIG_HOME: xdg_dir.to_s do
        File.open(config_path, "w") { |file| file << custom.to_yaml }
        expect(subject.to_h).to eq(custom)
      end
    end

    it "answers default hash when configuration file doesn't exist" do
      ClimateControl.modify XDG_CONFIG_HOME: xdg_dir.to_s do
        expect(subject.to_h).to eq({})
      end
    end

    context "with configuration file and custom defaults" do
      let :configuration do
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

      subject { described_class.new name, defaults: defaults }

      it "answers merged hash" do
        File.open(config_path, "w") { |file| file << configuration.to_yaml }

        ClimateControl.modify XDG_CONFIG_HOME: xdg_dir.to_s do
          expect(subject.to_h).to eq(merged)
        end
      end
    end
  end
end
