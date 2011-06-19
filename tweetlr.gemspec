Gem::Specification.new do |s|
  s.name        = "tweetlr"
  s.version     = "0.1.4pre"
  s.author      = "Sven Kraeuter"
  s.email       = "mail@svenkraeuter.com"
  s.homepage    = "http://github.com/5v3n/#{s.name}"
  s.summary     = "tweetlr crawls twitter for a given term, extracts photos out of the collected tweets' short urls and posts the images to tumblr."
  s.description = s.summary

  s.rubyforge_project = s.name
  s.extra_rdoc_files = %w(README.md LICENSE)

  s.add_dependency "daemons",      "~> 1.1.3"
  s.add_dependency "eventmachine", "~> 0.12.10"
  s.add_dependency "curb",         "~> 0.7.15"
  s.add_dependency "json",         "~> 1.5.1"

  s.add_development_dependency "rspec",            "~> 2.6.0"
  s.add_development_dependency "autotest",         "~> 4.4.6"
  s.add_development_dependency "autotest-growl",   "~> 0.2.9"
  s.add_development_dependency "autotest-fsevent", "~> 0.2.5"
  s.add_development_dependency "rdoc"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
