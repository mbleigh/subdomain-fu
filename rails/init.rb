require 'subdomain-fu'

ActionController::Base.send :include, SubdomainFu::Controller

ActionController::Routing::RouteSet.send :include, SubdomainFu::RouteSetExtensions
ActionController::Routing::Route.send :include, SubdomainFu::RouteExtensions

RAILS_DEFAULT_LOGGER.info("** SubdomainFu: initialized properly")