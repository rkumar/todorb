# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{todorb}
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Rahul Kumar"]
  s.date = %q{2010-06-23}
  s.default_executable = %q{todorb}
  s.description = %q{command-line program that manages a todo list text file, incl subtasks }
  s.email = %q{sentinel1879@gmail.com}
  s.executables = ["todorb"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.markdown"
  ]
  s.files = [
    "CHANGELOG.rdoc",
     "LICENSE",
     "Makefile",
     "README.markdown",
     "Rakefile",
     "VERSION",
     "bin/todorb",
     "lib/common/cmdapp.rb",
     "lib/common/colorconstants.rb",
     "lib/common/sed.rb",
     "lib/todorb.rb",
     "tests/Makefile",
     "tests/README",
     "tests/aggregate-results.sh",
     "tests/clean.sh",
     "tests/data.1",
     "tests/data.2",
     "tests/dataset1.txt",
     "tests/recreate.sh",
     "tests/rtest2.sh",
     "tests/t0001-help.sh",
     "tests/t0002-subc_help.sh",
     "tests/t0003-add.sh",
     "tests/t0004-list.sh",
     "tests/t0005-pri.sh",
     "tests/t0006-pri_sort.sh",
     "tests/t0007-status.sh",
     "tests/t0008-addsub.sh",
     "tests/t0009-del.sh",
     "tests/test-lib.sh",
     "todorb.gemspec"
  ]
  s.homepage = %q{http://github.com/rkumar/todorb}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{todorb}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{comprehensive command-line todo list manager with subtasks and more}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<subcommand>, [">= 0"])
    else
      s.add_dependency(%q<subcommand>, [">= 0"])
    end
  else
    s.add_dependency(%q<subcommand>, [">= 0"])
  end
end

