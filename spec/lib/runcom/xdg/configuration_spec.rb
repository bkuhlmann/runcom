# frozen_string_literal: true

require "spec_helper"

RSpec.describe Runcom::XDG::Configuration do
  describe ".home_dir" do
    it "answers default dir" do
      path = File.join ENV["HOME"], ".config"
      expect(described_class.home_dir).to eq(path)
    end

    it "answers custom dir" do
      path = "/some/custom/path"

      ClimateControl.modify XDG_CONFIG_HOME: path do
        expect(described_class.home_dir).to eq(path)
      end
    end
  end

  describe ".dirs" do
    it "answers default array" do
      expect(described_class.dirs).to contain_exactly("/etc/xdg")
    end

    it "answers custom array" do
      ClimateControl.modify XDG_CONFIG_DIRS: "/one:/two:/three" do
        expect(described_class.dirs).to contain_exactly("/one", "/two", "/three")
      end
    end
  end

  describe ".computed_dirs", :temp_dir do
    let(:home_dir) { Pathname %(#{ENV["HOME"]}/.config) }
    let(:test_dir) { Pathname "#{temp_dir}/test" }
    before { FileUtils.mkdir_p test_dir }

    it "answers default array" do
      if ENV["CI"] == "true"
        expect(described_class.computed_dirs).to contain_exactly(home_dir, Pathname("/etc/xdg"))
      else
        expect(described_class.computed_dirs).to contain_exactly(home_dir)
      end
    end

    it "answers custom array" do
      extra_dir = Pathname "#{temp_dir}/extra"
      FileUtils.mkdir_p extra_dir

      ClimateControl.modify XDG_CONFIG_DIRS: "#{test_dir}:#{extra_dir}" do
        expect(described_class.computed_dirs).to contain_exactly(
          home_dir,
          test_dir,
          extra_dir
        )
      end
    end

    it "ignores paths that do not exist" do
      bogus_dir = Pathname "#{temp_dir}/bogus"

      ClimateControl.modify XDG_CONFIG_DIRS: "#{test_dir}:#{bogus_dir}" do
        expect(described_class.computed_dirs).to contain_exactly(
          home_dir,
          test_dir
        )
      end
    end
  end

  describe ".computed_dir", :temp_dir do
    let(:test_dir) { Pathname "#{temp_dir}/config" }
    before { FileUtils.mkdir_p test_dir }

    it "answers computed directory" do
      ClimateControl.modify XDG_CONFIG_HOME: test_dir.to_s do
        expect(described_class.computed_dir).to eq(test_dir)
      end
    end
  end
end
