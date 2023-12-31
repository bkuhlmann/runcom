# frozen_string_literal: true

require "spec_helper"

RSpec.describe Runcom::Data do
  using Refinements::Pathname

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

  describe "#initial" do
    it "answers initial path" do
      expect(data.initial).to eq(path)
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

  describe "#active" do
    it "answers file path when it exists" do
      file_path = home_dir.join(path).deep_touch
      expect(data.active).to eq(file_path)
    end
  end

  describe "#passive" do
    it "answers global path when it doesn't exist" do
      expect(data.passive).to eq(temp_dir.join("data", path))
    end
  end

  describe "#global" do
    it "answers global path" do
      expect(data.global).to eq(temp_dir.join("data", path))
    end
  end

  describe "#local" do
    it "answers local path" do
      expect(data.local).to eq(Bundler.root.join(".local/share", path))
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

  shared_examples "a string" do |message|
    it "answers environment settings" do
      expect(data.public_send(message)).to eq(
        "XDG_DATA_HOME=#{Bundler.root.join ".local/share"}:#{home_dir} " \
        "XDG_DATA_DIRS=#{temp_dir}/one:#{temp_dir}/two"
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
      %r(
        \A
        \#<
        #{described_class}:\d+\s
        XDG_DATA_HOME=#{Bundler.root.join ".local/share"}:#{home_dir}\s
        XDG_DATA_DIRS=#{temp_dir}/one:#{temp_dir}/two
        >
        \Z
      )x
    end

    it "answers current environment" do
      expect(data.inspect).to match(pattern)
    end
  end
end
