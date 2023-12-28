# frozen_string_literal: true

require "spec_helper"

RSpec.describe Runcom::Paths::Common do
  using Refinements::Pathname

  subject :path do
    described_class.new test_path, context: Runcom::Context.new(xdg: XDG::Data, environment:)
  end

  include_context "with temporary directory"

  let(:test_path) { "test/example.txt" }

  let :environment do
    {
      "HOME" => "/home",
      "XDG_DATA_HOME" => temp_dir,
      "XDG_DATA_DIRS" => "#{temp_dir}/one:#{temp_dir}/two"
    }
  end

  describe "#relative" do
    it "answers relative path when resembling a path" do
      expect(path.relative).to eq(Pathname("test/example.txt"))
    end

    context "with empty string" do
      let(:test_path) { "" }

      it "answers empty path" do
        expect(path.relative).to eq(Pathname(""))
      end
    end

    context "with nil" do
      let(:test_path) { nil }

      it "answers empty path" do
        expect(path.relative).to eq(Pathname(""))
      end
    end

    context "with pathname" do
      let(:test_path) { Pathname "test/example.txt" }

      it "answers relative path" do
        expect(path.relative).to eq(Pathname("test/example.txt"))
      end
    end
  end

  describe "#namespace" do
    it "answers parent directory with relative path" do
      expect(path.namespace).to eq(Pathname("test"))
    end

    context "with empty path" do
      let(:test_path) { "" }

      it "answers parent directory" do
        expect(path.namespace).to eq(Pathname(".."))
      end
    end
  end

  describe "#file_name" do
    it "answers file name" do
      expect(path.file_name).to eq(Pathname("example.txt"))
    end

    context "with empty path" do
      let(:test_path) { "" }

      it "answers empty file name" do
        expect(path.file_name).to eq(Pathname(""))
      end
    end
  end

  describe "#active" do
    it "answers path when file exists" do
      file_path = temp_dir.join("test").make_path.join("example.txt").touch
      expect(path.active).to eq(file_path)
    end

    it "answers nil when path is a directory" do
      temp_dir.join("one/test/example.txt").make_path
      expect(path.active).to be(nil)
    end

    it "answers nil when path doesn't exist" do
      expect(path.active).to be(nil)
    end

    context "with empty path" do
      let(:test_path) { "" }

      it "answers nil" do
        expect(path.active).to be(nil)
      end
    end
  end

  describe "#passive" do
    it "answers active path when path exists" do
      file_path = temp_dir.join("test").make_path.join("example.txt").touch
      expect(path.passive).to eq(file_path)
    end

    it "answers passive path when path doesn't exist" do
      expect(path.passive).to eq(temp_dir.join(test_path))
    end

    context "with empty path" do
      let(:test_path) { "" }

      it "answers global path" do
        expect(path.passive).to eq(temp_dir)
      end
    end

    context "with nil path" do
      let(:test_path) { nil }

      it "answers global path" do
        expect(path.passive).to eq(temp_dir)
      end
    end
  end

  describe "#global" do
    it "answers global path" do
      expect(path.global).to eq(temp_dir.join("test/example.txt"))
    end
  end

  describe "#local" do
    it "relative path as expanded path" do
      expect(path.local).to eq(Pathname.pwd.join(".local/share/test/example.txt"))
    end
  end

  describe "#all" do
    it "answers paths with namespace and file path" do
      expect(path.all).to eq(
        [
          Bundler.root.join(".local/share/test/example.txt"),
          temp_dir.join("test/example.txt"),
          temp_dir.join("one/test/example.txt"),
          temp_dir.join("two/test/example.txt")
        ]
      )
    end

    context "with namespace only" do
      let(:test_path) { "test" }

      it "answers paths with namespace only" do
        expect(path.all).to eq(
          [
            Bundler.root.join(".local/share/test"),
            temp_dir.join("test"),
            temp_dir.join("one", "test"),
            temp_dir.join("two", "test")
          ]
        )
      end
    end

    context "with empty path" do
      let(:test_path) { "" }

      it "answes something" do
        expect(path.all).to eq(
          [
            Bundler.root.join(".local/share"),
            temp_dir,
            temp_dir.join("one"),
            temp_dir.join("two")
          ]
        )
      end
    end
  end

  describe "#inspect" do
    it "answers environment settings" do
      expect(path.inspect).to eq(
        "XDG_DATA_HOME=#{Bundler.root}/.local/share:#{temp_dir} " \
        "XDG_DATA_DIRS=#{temp_dir}/one:#{temp_dir}/two"
      )
    end
  end
end
