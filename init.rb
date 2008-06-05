require 'subdomain_fu'

ActionController::Base.send :include, SubdomainFu::Controller

ActionController::Routing::RouteSet.send :include, SubdomainFu::RouteSetExtensions
ActionController::Routing::Route.send :include, SubdomainFu::RouteExtensions