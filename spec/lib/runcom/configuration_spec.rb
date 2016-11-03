# frozen_string_literal: true

require "spec_helper"

RSpec.describe Runcom::Configuration, :temp_dir do
  let(:file_name) { ".testrc" }
  subject { described_class.new file_name: file_name }

  describe "#local?" do
    it "answers true when local configuration file exists" do
      Dir.chdir temp_dir do
        FileUtils.touch subject.local_path
        expect(subject.local?).to eq(true)
      end
    end

    it "answers false when local configuration file doesn't exist" do
      Dir.chdir temp_dir do
        expect(subject.local?).to eq(false)
      end
    end
  end

  describe "#global?" do
    it "answers true when global configuration file exists" do
      ClimateControl.modify HOME: temp_dir do
        FileUtils.touch subject.global_path
        expect(subject.global?).to eq(true)
      end
    end

    it "answers false when global configuration file doesn't exist" do
      ClimateControl.modify HOME: temp_dir do
        expect(subject.global?).to eq(false)
      end
    end
  end

  describe "#local_path" do
    it "answers default file path" do
      expect(subject.local_path).to eq(File.join(Dir.pwd, file_name))
    end

    it "answers custom file path" do
      subject = described_class.new file_name: file_name
      expect(subject.local_path).to eq(File.join(Dir.pwd, file_name))
    end
  end

  describe "#global_path" do
    it "answers default file path" do
      expect(subject.global_path).to eq(File.join(ENV["HOME"], file_name))
    end

    it "answers custom file path" do
      subject = described_class.new file_name: file_name
      expect(subject.global_path).to eq(File.join(ENV["HOME"], file_name))
    end
  end

  describe "#computed_path" do
    context "when local configuration exists" do
      let(:local_file) { File.join temp_dir, file_name }
      before { FileUtils.touch local_file }

      it "answers local file path" do
        Dir.chdir temp_dir do
          expect(subject.computed_path).to eq(subject.local_path)
        end
      end
    end

    context "when local configuration doesn't exists" do
      it "answers global file path" do
        Dir.chdir temp_dir do
          expect(subject.computed_path).to eq(subject.global_path)
        end
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
      subject { described_class.new file_name: file_name }

      it "merges custom settings" do
        ClimateControl.modify HOME: temp_dir do
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

      subject { described_class.new file_name: file_name, defaults: default_settings }

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

        ClimateControl.modify HOME: temp_dir do
          expect(subject.merge(custom_settings)).to eq(modified_settings)
        end
      end
    end
  end

  describe "#to_h" do
    let(:global_file) { File.join temp_dir, file_name }
    let(:local_dir) { File.join temp_dir, "local" }
    let(:local_file) { File.join local_dir, file_name }
    let(:global_defaults) { {remove: {comments: "# encoding: UTF-8"}} }
    let(:local_defaults) { {add: {comments: "#! /usr/bin/ruby"}} }
    subject { described_class.new file_name: file_name }

    context "when using global path" do
      before { File.open(global_file, "w") { |file| file << global_defaults.to_yaml } }

      it "answers global hash" do
        ClimateControl.modify HOME: temp_dir do
          expect(subject.to_h).to eq(global_defaults)
        end
      end
    end

    context "when using local path" do
      before do
        FileUtils.mkdir_p local_dir
        File.open(global_file, "w") { |file| file << global_defaults.to_yaml }
        File.open(local_file, "w") { |file| file << local_defaults.to_yaml }
      end

      it "answers local hash" do
        ClimateControl.modify HOME: temp_dir do
          Dir.chdir local_dir do
            expect(subject.to_h).to eq(local_defaults)
          end
        end
      end
    end

    context "when configuration file doesn't exist" do
      it "answers default settings" do
        ClimateControl.modify HOME: temp_dir do
          expect(subject.to_h).to eq({})
        end
      end
    end

    context "when using custom defaults" do
      let :defaults do
        {
          remove: {
            comments: "# frozen_string_literal: true",
            whitelist: []
          }
        }
      end
      subject { described_class.new file_name: file_name, defaults: defaults }
      before { File.open(global_file, "w") { |file| file << global_defaults.to_yaml } }

      it "answers merged hash with globals taking precedence over defaults" do
        modified_hash = {
          remove: {
            comments: "# encoding: UTF-8",
            whitelist: []
          }
        }

        ClimateControl.modify HOME: temp_dir do
          expect(subject.to_h).to eq(modified_hash)
        end
      end
    end
  end
end
