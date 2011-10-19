require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "subdomain-fu"
    gemspec.rubyforge_project = 'subdomain-fu'
    gemspec.summary = "SubdomainFu is a Rails plugin that provides subdomain routing and URL writing helpers."
    gemspec.email = "michael@intridea.com"
    gemspec.homepage = "http://github.com/mbleigh/subdomain-fu"
    gemspec.files =  FileList["[A-Z]*", "{lib}/**/*"] - FileList["**/*.log"]
    gemspec.description = "SubdomainFu is a Rails plugin to provide all of the basic functionality necessary to handle multiple subdomain applications (such as Basecamp-esque subdomain accounts and more)."
    gemspec.authors = ["Michael Bleigh"]
  end
  Jeweler::GemcutterTasks.new
  FileList['tasks/**/*.rake'].each { |task| import task }
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

begin
  require 'rspec/core/rake_task'

  task :cleanup_rcov_files do
    rm_rf 'coverage.data'
  end

  desc "Run all specs."
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = %w[--color]
  end

  namespace :spec do
    desc "Run all specs using rcov."
    RSpec::Core::RakeTask.new(:rcov => :cleanup_rcov_files) do |t|
      t.rcov = true
      t.rcov_opts = '-Ilib:spec --exclude "gems/.*,features"'
      t.rcov_opts << %[--text-report --sort coverage --html --aggregate coverage.data]
    end
  end

  task :default => :spec
rescue LoadError
  puts "RSpec-2 not available."
end
