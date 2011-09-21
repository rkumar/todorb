require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "todorb"
    gem.summary = %Q{comprehensive command-line todo list manager with subtasks and more }
    gem.description = %Q{command-line program that manages a todo list text file, incl subtasks, status, priorities etc }
    gem.email = "sentinel1879@gmail.com"
    gem.homepage = "http://github.com/rkumar/todorb"
    gem.authors = ["Rahul Kumar"]
    gem.rubyforge_project = "todorb"
    #gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
    gem.add_development_dependency "subcommand", ">= 1.0.5"
    gem.add_dependency "subcommand", ">= 1.0.5"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

#require 'rake/testtask'
#Rake::TestTask.new(:test) do |test|
  #test.libs << 'lib' << 'test'
  #test.pattern = 'test/**/test_*.rb'
  #test.verbose = true
#end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "todorb #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end

