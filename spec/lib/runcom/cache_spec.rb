# frozen_string_literal: true

require "spec_helper"

RSpec.describe Runcom::Cache do
  using Refinements::Pathnames

  subject(:cache) { described_class.new path, context: context }

  include_context "with temporary directory"

  let(:path) { Pathname "test/example.txt" }
  let(:home_dir) { temp_dir.join ".cache" }
  let(:context) { Runcom::Context.new xdg: XDG::Cache, environment: environment }
  let :environment do
    {
      "HOME" => "/home",
      "XDG_CACHE_HOME" => home_dir
    }
  end

  describe "#relative" do
    it "answers relative path" do
      expect(cache.relative).to eq(path)
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

  describe "#current" do
    it "answers file path when it exists" do
      file_path = home_dir.join(path).make_path
      expect(cache.current).to eq(file_path)
    end
  end

  describe "#all" do
    it "answers all paths" do
      expect(cache.all).to contain_exactly(home_dir.join(path))
    end
  end

  describe "#inspect" do
    it "answers environment settings" do
      expect(cache.inspect).to eq("XDG_CACHE_HOME=#{home_dir}")
    end
  end
end
