# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','rnote','version.rb'])
spec = Gem::Specification.new do |s| 
  s.name = 'rnote'
  s.version = Rnote::VERSION
  s.author = 'Jason Stillwell'
  s.email = 'dragonfax@gmail.com'
  s.homepage = 'http://github.com/dragonfax/evernote'
  s.platform = Gem::Platform::RUBY
  s.summary = 'CLI to Evernote'
  s.files = %w(
bin/rnote
lib/rnote/version.rb
lib/rnote.rb
  )
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc','rnote.rdoc']
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
