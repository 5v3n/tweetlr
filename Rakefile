require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'

spec = Gem::Specification.new do |s|
  s.name = 'newproject'
  s.version = '0.0.1'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.md', 'LICENSE']
  s.summary = 'a new project'
  s.description = s.summary
  s.author = 'Sven Kraeuter'
  s.email = 'mail@5v3n.com'
  s.homepage = "http://github.com/5v3n/#{s.name}"
  # s.executables = ['your_executable_here']
  s.files = %w(LICENSE README.md Rakefile) + Dir.glob("{bin,lib,spec}/**/*")
  s.require_path = "lib"
  s.bindir = "bin"
end

Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = true
  p.need_zip = true
end

Rake::RDocTask.new do |rdoc|
  files =['README.md', 'LICENSE', 'lib/**/*.rb']
  rdoc.rdoc_files.add(files)
  rdoc.main = "README.md" # page to start on
  rdoc.title = "newproject Docs" # <--- enter name manually!
  rdoc.rdoc_dir = 'doc/rdoc' # rdoc output folder
  rdoc.options << '--line-numbers'
end

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*.rb']
end
