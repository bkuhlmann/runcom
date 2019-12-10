# frozen_string_literal: true

require "spec_helper"

RSpec.describe Runcom::Paths::Common, :temp_dir do
  subject(:custom) { described_class.new path, context: context }

  let(:path) { "test/example.txt" }
  let(:context) { Runcom::Context.new xdg: XDG::Data, environment: environment }

  let :environment do
    {
      "HOME" => "/home",
      "XDG_DATA_HOME" => temp_dir,
      "XDG_DATA_DIRS" => "#{temp_dir}/one:#{temp_dir}/two"
    }
  end

  describe "#relative" do
    it "answers relative path with string" do
      expect(custom.relative).to eq(Pathname("test/example.txt"))
    end

    context "with empty string" do
      let(:path) { "" }

      it "answers empty path" do
        expect(custom.relative).to eq(Pathname(""))
      end
    end

    context "with nil" do
      let(:path) { nil }

      it "fails with type error" do
        expectation = -> { custom.relative }
        expect(&expectation).to raise_error(TypeError, /conversion of nil/)
      end
    end

    context "with pathname" do
      let(:path) { Pathname "test/example.txt" }

      it "answers relative path" do
        expect(custom.relative).to eq(Pathname("test/example.txt"))
      end
    end
  end

  describe "#namespace" do
    it "answers namespace with relative path" do
      expect(custom.namespace).to eq(Pathname("test"))
    end

    context "with empty path" do
      let(:path) { "" }

      it "answers namespace" do
        expect(custom.namespace).to eq(Pathname(".."))
      end
    end
  end

  describe "#file_name" do
    it "answers file name" do
      expect(custom.file_name).to eq(Pathname("example.txt"))
    end

    context "with empty path" do
      let(:path) { "" }

      it "answers empty file name" do
        expect(custom.file_name).to eq(Pathname(""))
      end
    end
  end

  describe "#current" do
    it "answers path when path exists" do
      file_path = temp_dir.join "test", "example.txt"
      FileUtils.mkpath file_path

      expect(custom.current).to eq(file_path)
    end

    it "answers nil when path doesn't exist" do
      expect(custom.current).to eq(nil)
    end

    context "with empty path" do
      let(:path) { "" }

      it "answers home directory" do
        expect(custom.current).to eq(temp_dir)
      end
    end
  end

  describe "#all" do
    it "answers paths with namespace and file path" do
      expect(custom.all).to contain_exactly(
        temp_dir.join("test", "example.txt"),
        temp_dir.join("one", "test", "example.txt"),
        temp_dir.join("two", "test", "example.txt")
      )
    end

    context "with namespace only" do
      let(:path) { "test" }

      it "answers paths with namespace only" do
        expect(custom.all).to contain_exactly(
          temp_dir.join("test"),
          temp_dir.join("one", "test"),
          temp_dir.join("two", "test")
        )
      end
    end

    context "with empty path" do
      let(:path) { "" }

      it "answes something" do
        expect(custom.all).to contain_exactly(
          temp_dir,
          temp_dir.join("one"),
          temp_dir.join("two")
        )
      end
    end
  end

  describe "#inspect" do
    it "answers environment settings" do
      expect(custom.inspect).to eq(
        "XDG_DATA_HOME=#{temp_dir} XDG_DATA_DIRS=#{temp_dir}/one:#{temp_dir}/two"
      )
    end
  end
end
