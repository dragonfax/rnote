# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','evernote','version.rb'])
spec = Gem::Specification.new do |s| 
  s.name = 'evernote'
  s.version = Evernote::VERSION
  s.author = 'Jason Stillwell'
  s.email = 'dragonfax@gmail.com'
  s.homepage = 'http://github.com/dragonfax/evernote'
  s.platform = Gem::Platform::RUBY
  s.summary = 'CLI to Evernote'
  s.files = %w(
bin/evernote
lib/evernote/version.rb
lib/evernote.rb
  )
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc','evernote.rdoc']
  s.rdoc_options << '--title' << 'evernote' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'evernote'
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('aruba')
  s.add_runtime_dependency('gli','2.5.4')

	s.add_runtime_dependency('evernote-thrift')
	s.add_runtime_dependency('evernote_oauth')

end
