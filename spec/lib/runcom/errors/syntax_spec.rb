# frozen_string_literal: true

require "spec_helper"

RSpec.describe Runcom::Errors::Syntax do
  subject { described_class.new "Test" }

  describe "#message" do
    it "answers formatted message" do
      expect(subject.message).to eq("Invalid configuration Test.")
    end
  end
end
