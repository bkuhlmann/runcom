# frozen_string_literal: true

require "spec_helper"

RSpec.describe Runcom::Cache, :temp_dir do
  subject(:cache) { described_class.new name: name, environment: environment }

  let(:name) { "test" }
  let(:cache_dir) { Pathname "#{temp_dir}/.cache/#{name}" }
  let(:home) { Runcom::Pair.new "HOME", "/home" }
  let(:environment) { home.to_env.merge "XDG_CACHE_HOME" => cache_dir }

  describe "#initialize" do
    context "with default arguments" do
      subject(:cache) { described_class.new }

      it "answers default name" do
        expect(cache.name).to eq(nil)
      end

      it "answers default home path" do
        expect(cache.home).to eq(Runcom::Paths::Friendly)
      end

      it "answers default environment" do
        expect(cache.environment).to eq(ENV)
      end
    end

    context "with custom arguments" do
      subject :cache do
        described_class.new name: "test",
                            home: Runcom::Paths::Standard,
                            environment: Hash.new
      end

      it "answers custom name" do
        expect(cache.name).to eq("test")
      end

      it "answers custom home path" do
        expect(cache.home).to eq(Runcom::Paths::Standard)
      end

      it "answers custom environment" do
        expect(cache.environment).to eq(Hash.new)
      end
    end
  end

  describe "#path" do
    it "answers path when it exists" do
      FileUtils.mkdir_p cache_dir
      expect(cache.path).to eq(cache_dir)
    end

    it "answers nil when path doesn't exist" do
      expect(cache.path).to eq(nil)
    end
  end

  describe "#paths" do
    it "answers all paths" do
      expect(cache.paths).to contain_exactly(cache_dir)
    end
  end
end
