require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'

require 'spec/rake/spectask'

desc "Compiles and tests the build"
task :default => [ :spec ]

CLEAN.include [
  "*.gem", 'pkg', 'doc/coverage', 'doc/rdoc'
]

Gem::manage_gems
SPEC = Gem::Specification.new do |s|
  # Stuff I might want to tweak.
  s.summary = "A Ruby interface to the Mac OS X FSEvent library."
  s.version = "0.1"

  # Usual constants
  s.name = File.basename(File.dirname(File.expand_path(__FILE__)))
  s.author = "Graeme Mathieson"
  s.email = "mathie@rubaidh.com"
  s.homepage = "http://www.rubaidh.com/fsevents"
  s.platform = Gem::Platform::RUBY
  s.description = s.summary
  s.files = (%w(CHANGELOG Rakefile README) +
      FileList["{bin,doc,lib,spec}/**/*"].to_a).delete_if do |f|
    f =~ /^\._/ ||
    f =~ /doc\/(rdoc|coverage)/ ||
    f =~ /\.(so|bundle)$/
  end
  s.require_path = "lib"
  s.bindir = 'bin'
  s.test_files = FileList["spec/*.rb"].to_a

  # Documentation
  s.has_rdoc = true
  s.extra_rdoc_files = ['README', 'CHANGELOG']
end

Spec::Rake::SpecTask.new do |spec|
  spec.spec_files = FileList['spec/**/*_spec.rb']
  spec.rcov = true
  spec.rcov_dir = "doc/coverage"
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'doc/rdoc'
  rdoc.options += ['--line-numbers', '--inline-source']
  rdoc.main = 'README'
  rdoc.rdoc_files.add [SPEC.extra_rdoc_files, 'lib/**/*.rb'].flatten
end

Rake::GemPackageTask.new(SPEC)
