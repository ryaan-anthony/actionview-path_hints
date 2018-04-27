#!/usr/bin/env rake

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'action_view/path_hints/version'

desc "Release version #{ActionViewPathHints::VERSION} of the gem"
task :release do

  system "git tag -a v#{ActionViewPathHints::VERSION} -m 'Tagging #{ActionViewPathHints::VERSION}'"
  system 'git push --tags'

  system "gem build actionview-path_hints.gemspec"
  system "gem push actionview-path_hints-#{ActionViewPathHints::VERSION}.gem"
  system "rm actionview-path_hints-#{ActionViewPathHints::VERSION}.gem"
end
