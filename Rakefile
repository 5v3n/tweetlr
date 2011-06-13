require 'bundler'
Bundler::GemHelper.install_tasks

require 'rdoc/task'
require 'rspec/core/rake_task'

RDoc::Task.new do |rdoc|
  files = ['README.md', 'LICENSE', 'lib/**/*.rb']
  rdoc.rdoc_files.add(files)
  rdoc.main = "README.md"           # page to start on
  rdoc.title = "tweetlr Docs"       # <--- enter name manually!
  rdoc.rdoc_dir = 'doc/rdoc'        # rdoc output folder
  rdoc.options << '--line-numbers'
end

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = %w(-c)
end

task :default => :spec
task :test => :spec
