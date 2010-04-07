require 'action_controller/base'

# Allow whatever Ruby Package tool is being used to manage load paths.  gem auto adds the gem's lib dir to load path.
require 'subdomain-fu' unless defined?(SubdomainFu)

ActionController::Base.send :include, SubdomainFu::Controller
