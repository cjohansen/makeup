# -*- encoding: utf-8 -*-
dir = File.expand_path(File.dirname(__FILE__))
require File.join(dir, "lib", "makeup/version.rb")

Gem::Specification.new do |s|
  s.name        = "makeup"
  s.version     = Makeup::VERSION
  s.authors     = ["Christian Johansen"]
  s.email       = ["christian@gitorious.org"]
  s.homepage    = "https://gitorious.org/gitorious/makeup"
  s.license     = "MIT"
  s.summary     = %q{Pretty markup}
  s.description = <<-DESC
Makeup provides markup rendering and code highlighting. It renders all kinds of
markup formats using GitHub::Markup, and implements "fenced code blocks" for
markdown files.
  DESC

  s.rubyforge_project = "makeup"

  s.add_dependency "pygments.rb", "~>0.4", "<= 0.5.2"
  s.add_dependency "github-linguist", "~>2.8"
  s.add_dependency "github-markup", "~> 1.0"
  s.add_dependency "htmlentities", "~> 4.3"
  s.add_dependency "loofah", "~> 1.2"

  s.add_development_dependency "minitest", "~> 2.0"
  s.add_development_dependency "rake", "~> 0.9"
  s.add_development_dependency "redcarpet", "2.2.0"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
