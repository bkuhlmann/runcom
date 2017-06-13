# frozen_string_literal: true

require "spec_helper"

RSpec.describe Runcom::Configuration, :temp_dir do
  let(:project_name) { "test" }
  let(:xdg_dir) { Pathname "#{temp_dir}/.config" }
  let(:config_dir) { Pathname "#{xdg_dir}/#{project_name}" }
  let(:config_path) { Pathname "#{config_dir}/configuration.yml" }
  subject { described_class.new project_name: project_name }
  before { FileUtils.mkdir_p config_dir }

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
            whitelist: [".gemspec"]
          }
        }
      end

      let :merged_settings do
        {
          add: {
            comments: "encoding: UTF-8",
            whitelist: [".gemspec"]
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
            whitelist: []
          },
          remove: {
            comments: "",
            whitelist: []
          }
        }
      end

      let :custom_settings do
        {
          add: {
            whitelist: [".gemspec"]
          },
          remove: {
            comments: "# encoding: UTF-8"
          }
        }
      end

      subject { described_class.new project_name: project_name, defaults: default_settings }

      it "merges custom settings" do
        modified_settings = {
          add: {
            comments: "",
            whitelist: [".gemspec"]
          },
          remove: {
            comments: "# encoding: UTF-8",
            whitelist: []
          }
        }

        ClimateControl.modify XDG_CONFIG_HOME: xdg_dir.to_s do
          expect(subject.merge(custom_settings)).to eq(modified_settings)
        end
      end
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
            whitelist: []
          }
        }
      end

      let :merged do
        {
          remove: {
            comments: "# encoding: UTF-8",
            whitelist: []
          }
        }
      end

      subject { described_class.new project_name: project_name, defaults: defaults }

      it "answers merged hash" do
        File.open(config_path, "w") { |file| file << configuration.to_yaml }

        ClimateControl.modify XDG_CONFIG_HOME: xdg_dir.to_s do
          expect(subject.to_h).to eq(merged)
        end
      end
    end
  end
end
