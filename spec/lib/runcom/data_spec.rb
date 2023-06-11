# frozen_string_literal: true

require "spec_helper"

RSpec.describe Runcom::Data do
  using Refinements::Pathnames

  subject(:data) { described_class.new path, context: }

  include_context "with temporary directory"

  let(:path) { Pathname "test/example.txt" }
  let(:home_dir) { temp_dir.join "data" }
  let(:context) { Runcom::Context.new xdg: XDG::Data, environment: }

  let :environment do
    {
      "HOME" => "/home",
      "XDG_DATA_HOME" => home_dir,
      "XDG_DATA_DIRS" => "#{temp_dir}/one:#{temp_dir}/two"
    }
  end

  describe "#relative" do
    it "answers relative path" do
      expect(data.relative).to eq(path)
    end
  end

  describe "#namespace" do
    it "answers namespace" do
      expect(data.namespace).to eq(Pathname("test"))
    end
  end

  describe "#file_name" do
    it "answers file name" do
      expect(data.file_name).to eq(Pathname("example.txt"))
    end
  end

  describe "#current" do
    it "answers file path when it exists" do
      file_path = home_dir.join(path).deep_touch
      expect(data.current).to eq(file_path)
    end
  end

  describe "#all" do
    it "answers all paths" do
      expect(data.all).to contain_exactly(
        Bundler.root.join(".local/share/test/example.txt"),
        home_dir.join(path),
        temp_dir.join("one", path),
        temp_dir.join("two", path)
      )
    end
  end

  describe "#inspect" do
    it "answers environment settings" do
      expect(data.inspect).to eq(
        %(XDG_DATA_HOME=#{Bundler.root.join ".local/share"}:#{home_dir} ) \
        "XDG_DATA_DIRS=#{temp_dir}/one:#{temp_dir}/two"
      )
    end
  end
end
