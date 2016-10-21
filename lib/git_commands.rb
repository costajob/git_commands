lib = File.expand_path("../../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "git_commands/version"
require "git_commands/computer"
require "git_commands/cli"
