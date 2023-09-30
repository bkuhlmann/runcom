# frozen_string_literal: true

require "xdg"
require "zeitwerk"

Zeitwerk::Loader.new.then do |loader|
  loader.tag = File.basename __FILE__, ".rb"
  loader.push_dir __dir__
  loader.setup
end

# Main namespace.
module Runcom
end
