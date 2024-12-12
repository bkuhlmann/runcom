# frozen_string_literal: true

require "spec_helper"

RSpec.describe Runcom::Cache do
  using Refinements::Pathname

  subject(:cache) { described_class.new path, context: }

  include_context "with temporary directory"

  let(:path) { Pathname "test/example.txt" }
  let(:home_dir) { temp_dir.join ".cache" }
  let(:context) { Runcom::Context.new xdg: XDG::Cache, environment: }

  let :environment do
    {
      "HOME" => "/home",
      "XDG_CACHE_HOME" => home_dir
    }
  end

  describe "#initialize" do
    it "is frozen" do
      expect(cache.frozen?).to be(true)
    end
  end

  describe "#initial" do
    it "answers initial path" do
      expect(cache.initial).to eq(path)
    end
  end

  describe "#namespace" do
    it "answers namespace" do
      expect(cache.namespace).to eq(Pathname("test"))
    end
  end

  describe "#file_name" do
    it "answers file name" do
      expect(cache.file_name).to eq(Pathname("example.txt"))
    end
  end

  describe "#active" do
    it "answers file path when it exists" do
      file_path = home_dir.join(path).deep_touch
      expect(cache.active).to eq(file_path)
    end
  end

  describe "#passive" do
    it "answers global path when it doesn't exist" do
      expect(cache.passive).to eq(temp_dir.join(".cache", path))
    end
  end

  describe "#global" do
    it "answers global path" do
      expect(cache.global).to eq(temp_dir.join(".cache", path))
    end
  end

  describe "#local" do
    it "answers local path" do
      expect(cache.local).to eq(Bundler.root.join(".cache", path))
    end
  end

  describe "#all" do
    it "answers all paths" do
      expect(cache.all).to eq(
        [
          Bundler.root.join(".cache/test/example.txt"),
          home_dir.join(path)
        ]
      )
    end
  end

  shared_examples "a string" do |message|
    it "answers environment settings" do
      expect(cache.public_send(message)).to eq(
        "XDG_CACHE_HOME=#{Bundler.root.join ".cache"}:#{home_dir}"
      )
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
        XDG_CACHE_HOME=#{Bundler.root.join ".cache"}:#{home_dir}
        >
        \Z
      /x
    end

    it "answers current environment" do
      expect(cache.inspect).to match(pattern)
    end
  end
end
