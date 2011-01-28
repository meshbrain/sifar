require 'rubygems'
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
    gem.name = 'sifar'
    gem.homepage = 'http://github.com/meshbrain/sifar'
    gem.license = 'MIT'
    gem.summary = %Q{A library to generate strong passwords and check password strength.}
    gem.description = %Q{Sifar can be used to check for strong passwords. Apart from the standard tests for length and homogeneity, it can check passwords that sound and spell similar to a given word. Sifar can also generate passwords that satisfy the same criteria.}
    gem.email = 'contact@meshbrain.com'
    gem.authors = ['Suman Debnath']
    gem.add_dependency 'text', '~> 0.2.0'
    gem.add_development_dependency 'rspec', '~> 2.3.0'
    #gem.add_development_dependency 'bundler', '~> 1.0.0'
    gem.add_development_dependency 'jeweler', '~> 1.5.2'
    gem.add_development_dependency 'rcov', '>= 0'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
    spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
    spec.pattern = 'spec/**/*_spec.rb'
    spec.rcov = true
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
    version = File.exist?('VERSION') ? File.read('VERSION') : ''

    rdoc.rdoc_dir = 'rdoc'
    rdoc.title = 'sifar #{version}'
    rdoc.rdoc_files.include('README*')
    rdoc.rdoc_files.include('lib/**/*.rb')
end
