# frozen_string_literal: true

require "spec_helper"

RSpec.describe Runcom::Paths::Directory do
  subject(:directories) { described_class.new pair, environment }

  let(:home) { Runcom::Pair.new "HOME", "/home" }
  let(:environment) { home.to_env }

  describe "#default" do
    context "with single path" do
      let(:pair) { Runcom::Pair.new "TEST_DIRS", "/one" }

      it "answers array with one path" do
        expect(directories.default).to contain_exactly(Pathname("/one"))
      end
    end

    context "with multiple paths" do
      let(:pair) { Runcom::Pair.new "TEST_DIRS", "/one:/two:/three" }

      it "answers array with multiple paths" do
        expect(directories.default).to contain_exactly(
          Pathname("/one"),
          Pathname("/two"),
          Pathname("/three")
        )
      end
    end

    context "with tilda value" do
      let(:pair) { Runcom::Pair.new "TEST_DIRS", "~/test" }

      it "answers expanded paths" do
        path = Pathname File.join(ENV["HOME"], "test")
        expect(directories.default).to contain_exactly(path)
      end
    end

    context "with nil pair value" do
      let(:pair) { Runcom::Pair.new "TEST_DIRS", nil }

      it "answers empty array" do
        expect(directories.default).to eq([])
      end
    end

    context "with nil pair key and value" do
      let(:pair) { Runcom::Pair.new nil, nil }

      it "answers empty array" do
        expect(directories.default).to eq([])
      end
    end
  end

  describe "#dynamic" do
    context "with pair unset and environment set" do
      let(:pair) { Runcom::Pair.new "TEST_DIRS", nil }
      let(:environment) { home.to_env.merge "TEST_DIRS" => "/one:/two" }

      it "answers environment paths" do
        expect(directories.dynamic).to contain_exactly(
          Pathname("/one"),
          Pathname("/two")
        )
      end
    end

    context "with pair set and environment unset" do
      let(:pair) { Runcom::Pair.new "TEST_DIRS", "/one:/two" }

      it "answers default paths" do
        expect(directories.dynamic).to contain_exactly(
          Pathname("/one"),
          Pathname("/two")
        )
      end
    end

    context "with duplicate directories" do
      let(:pair) { Runcom::Pair.new "TEST_DIRS", "/one:/two:/one" }

      it "answers unique directories" do
        expect(directories.dynamic).to contain_exactly(
          Pathname("/one"),
          Pathname("/two")
        )
      end
    end

    context "with nil pair value" do
      let(:pair) { Runcom::Pair.new "TEST_DIRS", nil }

      it "answers empty array" do
        expect(directories.dynamic).to eq([])
      end
    end

    context "with nil pair key and value" do
      let(:pair) { Runcom::Pair.new nil, nil }

      it "answers empty array" do
        expect(directories.dynamic).to eq([])
      end
    end
  end
end