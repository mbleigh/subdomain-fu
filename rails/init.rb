# Add this path to ruby load path
$:.unshift "#{File.dirname(__FILE__)}/../lib"

require 'subdomain-fu' unless defined?(SubdomainFu)

ActionController::Base.send :include, SubdomainFu::Controller

RAILS_DEFAULT_LOGGER.info("** SubdomainFu: initialized properly")
