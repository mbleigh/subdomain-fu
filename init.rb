#Allow whatever Ruby Package tool is being used ot manage load paths.  gem auto adds the gem's lib dir to load path.
require 'subdomain-fu' unless defined?(SubdomainFu)

ActionController::Base.send :include, SubdomainFu::Controller

RAILS_DEFAULT_LOGGER.info("** SubdomainFu: initialized properly")
