# Ensure we require the local version and not one we might have installed already
require File.absolute_path(File.join([File.dirname(__FILE__),'lib','rnote','version.rb']))
require 'rake'
spec = Gem::Specification.new do |s| 
  s.name = 'rnote'
  s.version = Rnote::VERSION
  s.author = 'Jason Stillwell'
  s.email = 'dragonfax@gmail.com'
  s.homepage = 'http://github.com/dragonfax/rnote'
  s.platform = Gem::Platform::RUBY
  s.summary = 'CLI to Evernote'
  s.description = <<-EOF
    RNote is a command line tool for accessing Evernote.
    You can use it to find, create, and edit notes directly on the Evernote Cloud.
    RNote will launch your own EDITOR when you ask to edit a note. Much like git does for commit messages.
  EOF
  s.files = FileList['bin/rnote',"lib/**/*.rb"].to_a.select { |path| not ( path =~ /environment.rb$/ ) }
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['rnote.rdoc']
  s.rdoc_options << '--title' << 'rnote' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'rnote'
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('aruba')
  s.add_development_dependency('minitest-reporters')

  s.add_runtime_dependency('gli','2.5.4')
	s.add_runtime_dependency('evernote-thrift')
	s.add_runtime_dependency('evernote_oauth')
  s.add_runtime_dependency('mechanize')
  s.add_runtime_dependency('nokogiri')
  s.add_runtime_dependency('highline')


end
