# frozen_string_literal: true

require "spec_helper"

RSpec.describe Runcom::Runtime do
  using Refinements::Pathname

  subject(:runtime) { described_class.new path, context: }

  include_context "with temporary directory"

  let(:path) { Pathname "test/run" }
  let(:global_dir) { temp_dir.join "global" }
  let(:context) { Runcom::Context.new home: XDG::Paths::Any, xdg: XDG::Runtime, environment: }
  let(:environment) { {"XDG_RUNTIME_DIR" => global_dir} }

  describe "#initialize" do
    it "is frozen" do
      expect(runtime.frozen?).to be(true)
    end
  end

  describe "#initial" do
    it "answers initial path" do
      expect(runtime.initial).to eq(path)
    end
  end

  describe "#namespace" do
    it "answers namespace" do
      expect(runtime.namespace).to eq(Pathname("test"))
    end
  end

  describe "#file_name" do
    it "answers file name" do
      expect(runtime.file_name).to eq(Pathname("run"))
    end
  end

  describe "#active" do
    it "answers file path when it exists" do
      file_path = global_dir.join(path).touch_deep
      expect(runtime.active).to eq(file_path)
    end

    it "answers nil when path doesn't exist" do
      expect(runtime.active).to be(nil)
    end
  end

  describe "#passive" do
    it "answers file path when it exists" do
      global_dir.join(path).touch_deep
      expect(runtime.passive).to eq(global_dir.join(path))
    end

    it "answers nil when path doesn't exist" do
      expect(runtime.passive).to be(nil)
    end
  end

  describe "#global" do
    it "answers nil when path doesn't exist" do
      expect(runtime.global).to be(nil)
    end
  end

  describe "#local" do
    it "answers local path" do
      expect(runtime.local).to eq(global_dir.join(path))
    end
  end

  describe "#all" do
    it "answers all paths" do
      expect(runtime.all).to eq([global_dir.join(path)])
    end
  end

  shared_examples "a string" do |message|
    it "answers environment settings" do
      expect(runtime.public_send(message)).to eq("XDG_RUNTIME_DIR=#{global_dir}")
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
      /
        \A
        \#<
        #{described_class}:\d+\s
        XDG_RUNTIME_DIR=#{global_dir}
        >
        \Z
      /x
    end

    it "answers current environment" do
      expect(runtime.inspect).to match(pattern)
    end
  end
end
