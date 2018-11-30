# frozen_string_literal: true

require "spec_helper"

RSpec.describe Runcom::Paths::Friendly do
  subject(:path) { described_class.new pair, environment }

  let(:pair) { Runcom::Pair.new "TEST", "test" }
  let(:home) { Runcom::Pair.new "HOME", "/home" }
  let(:environment) { home.to_env }

  describe "#key" do
    it "answers key" do
      expect(path.key).to eq(pair.key)
    end
  end

  describe "#value" do
    it "answers value" do
      expect(path.value).to eq(pair.value)
    end
  end

  describe "#default" do
    it "answers relative path" do
      expect(path.default).to eq(Pathname("/home/test"))
    end
  end

  describe "#dynamic" do
    context "with default path" do
      let(:environment) { home.to_env.merge pair.to_env }

      it "answers default path" do
        expect(path.dynamic).to eq(Pathname("/home/test"))
      end
    end

    context "with dynamic path" do
      let(:environment) { home.to_env.merge pair.key => "dynamic" }

      it "answers dynamic path" do
        expect(path.dynamic).to eq(Pathname("/home/dynamic"))
      end
    end

    context "with existing path", :temp_dir do
      let(:environment) { home.to_env.merge pair.to_env }
      let(:test_path) { temp_dir.join "test" }

      before { FileUtils.mkdir_p test_path }

      it "answers dynamic path" do
        Dir.chdir temp_dir do
          expect(path.dynamic).to eq(test_path)
        end
      end
    end
  end
end
