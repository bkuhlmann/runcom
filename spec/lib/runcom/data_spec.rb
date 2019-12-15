# frozen_string_literal: true

require "spec_helper"

RSpec.describe Runcom::Data, :temp_dir do
  subject(:data) { described_class.new name: "test", environment: environment }

  let(:home_dir) { "#{temp_dir}/data" }
  let :environment do
    {
      "HOME" => "/home",
      "XDG_DATA_HOME" => home_dir,
      "XDG_DATA_DIRS" => "#{temp_dir}/one:#{temp_dir}/two"
    }
  end

  describe "#initialize" do
    context "with default arguments" do
      subject(:data) { described_class.new }

      it "answers default name" do
        expect(data.name).to eq(nil)
      end

      it "answers default home path" do
        expect(data.home).to eq(Runcom::Paths::Home)
      end

      it "answers default environment" do
        expect(data.environment).to eq(ENV)
      end
    end

    context "with custom arguments" do
      subject :data do
        described_class.new name: "test",
                            home: XDG::Paths::Standard,
                            environment: Hash.new
      end

      it "answers custom name" do
        expect(data.name).to eq("test")
      end

      it "answers custom home path" do
        expect(data.home).to eq(XDG::Paths::Standard)
      end

      it "answers custom environment" do
        expect(data.environment).to eq(Hash.new)
      end
    end
  end

  describe "#path" do
    it "answers path when it exists" do
      path = Pathname "#{home_dir}/test"
      FileUtils.mkdir_p path

      expect(data.path).to eq(path)
    end

    it "answers nil when path doesn't exist" do
      expect(data.path).to eq(nil)
    end
  end

  describe "#paths" do
    it "answers all paths" do
      expect(data.paths).to contain_exactly(
        Pathname("#{home_dir}/test"),
        Pathname("#{temp_dir}/one/test"),
        Pathname("#{temp_dir}/two/test")
      )
    end
  end

  describe "#inspect" do
    it "answers environment settings" do
      expect(data.inspect).to eq(
        "XDG_DATA_HOME=#{home_dir} XDG_DATA_DIRS=#{temp_dir}/one:#{temp_dir}/two"
      )
    end
  end
end
