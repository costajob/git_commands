$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "git_commands"
require "minitest/autorun"
require "tempfile"
require "fileutils"
require "mocks"

include Mocks

$VERBOSE = nil
