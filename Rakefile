require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rubygems/package_task'
require 'rdoc/task'
require 'rake/testtask'

spec = Gem::Specification.new do |s|
  s.name = 'tweetlr'
  s.version = '0.1.3pre'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.md', 'LICENSE']
  s.summary = %{tweetlr crawls twitter for a given term, extracts photos out of the collected tweets' short urls and posts the images to tumblr.}
  s.description = s.summary
  s.author = 'Sven Kraeuter'
  s.email = 'mail@svenkraeuter.com'
  s.homepage = "http://github.com/5v3n/#{s.name}"
  s.files = %w(LICENSE README.md Rakefile) + Dir.glob("{bin,lib}/**/*")
  s.require_path = "lib"
  s.executables  = ['tweetlr']
  s.add_dependency('daemons')
  s.add_dependency('eventmachine')
  s.add_dependency('curb')
end

Gem::PackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = true
  p.need_zip = true
end

RDoc::Task.new do |rdoc|
  files =['README.md', 'LICENSE', 'lib/**/*.rb']
  rdoc.rdoc_files.add(files)
  rdoc.main = "README.md" # page to start on
  rdoc.title = "tweetlr Docs" # <--- enter name manually!
  rdoc.rdoc_dir = 'doc/rdoc' # rdoc output folder
  rdoc.options << '--line-numbers'
end

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*.rb']
end
