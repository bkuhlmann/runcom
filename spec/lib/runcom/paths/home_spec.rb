# frozen_string_literal: true

require "spec_helper"

RSpec.describe Runcom::Paths::Home do
  using Refinements::Pathname

  subject(:path) { described_class.new pair, environment }

  include_context "with temporary directory"

  let(:pair) { XDG::Pair.new "TEST", "test" }
  let(:home) { XDG::Pair.new "HOME", "/home" }
  let(:environment) { home.to_env }

  describe "#initialize" do
    it "is frozen" do
      expect(path.frozen?).to be(true)
    end
  end

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
        expect(path.dynamic).to eq([Bundler.root.join("test"), Pathname("/home/test")])
      end
    end

    context "with dynamic path" do
      let(:environment) { home.to_env.merge pair.key => "dynamic" }

      it "answers dynamic path" do
        expect(path.dynamic).to eq([Bundler.root.join("test"), Pathname("/home/dynamic")])
      end
    end

    context "with existing path" do
      let(:environment) { home.to_env.merge pair.to_env }
      let(:test_path) { temp_dir.join "test" }

      before { test_path.make_path }

      it "answers dynamic path" do
        temp_dir.change_dir { expect(path.dynamic).to eq([test_path, Pathname("/home/test")]) }
      end
    end
  end

  shared_examples "a string" do |message|
    it "answers key and value" do
      expect(path.public_send(message)).to eq(%(TEST=#{Bundler.root.join "test"}:/home/test))
    end

    context "with empty pair" do
      let(:pair) { XDG::Pair.new }

      it "answers value only" do
        expect(path.public_send(message)).to eq(%("#{Bundler.root}:/home").undump)
      end
    end
  end

  describe "#to_s" do
    it_behaves_like "a string", :to_s
  end

  describe "#inspect" do
    it "answers key and value with custom pair" do
      expect(path.inspect).to match(
        %r(\A\#<#{described_class}:\d+ TEST=#{Bundler.root.join "test"}:/home/test>\Z)
      )
    end

    context "with empty pair" do
      let(:pair) { XDG::Pair.new }

      it "answers value only" do
        expect(path.inspect).to match(%r(\A\#<#{described_class}:\d+ #{Bundler.root}:/home>\Z))
      end
    end
  end
end
