require 'rake'
require 'spec/rake/spectask'

desc 'Default: run specs.'
task :default => :spec

desc 'Run the specs'
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts = ['--colour --format progress --loadby mtime --reverse']
  t.spec_files = FileList['spec/**/*_spec.rb']
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "subdomain-fu"
    gemspec.rubyforge_project = 'subdomain-fu'
    gemspec.summary = "SubdomainFu is a Rails plugin that provides subdomain routing and URL writing helpers."
    gemspec.email = "michael@intridea.com"
    gemspec.homepage = "http://github.com/mbleigh/subdomain-fu"
    gemspec.files =  FileList["[A-Z]*", "{lib,spec,rails}/**/*"] - FileList["**/*.log"]
    gemspec.description = "SubdomainFu is a Rails plugin to provide all of the basic functionality necessary to handle multiple subdomain applications (such as Basecamp-esque subdomain accounts and more)."
    gemspec.authors = ["Michael Bleigh"]
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

