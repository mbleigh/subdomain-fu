require 'subdomain_fu'
require 'subdomain_fu/url_rewriter'

ActionController::Base.send :include, SubdomainFu::Controller