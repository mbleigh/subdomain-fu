require 'action_dispatch/routing/route_set'

module ActionDispatch
  module Routing
    class RouteSet #:nodoc:
      def url_for_with_subdomains(options, path_segments=nil)
        if SubdomainFu.needs_rewrite?(options[:subdomain], (options[:host] || (@request && @request.host_with_port))) || options[:only_path] == false
          options[:only_path] = false if SubdomainFu.override_only_path?
          options[:host] = SubdomainFu.rewrite_host_for_subdomains(options.delete(:subdomain), options[:host] || (@request && @request.host_with_port))
        else
          options.delete(:subdomain)
        end
        url_for_without_subdomains(options)
      end
      alias_method_chain :url_for, :subdomains
    end
  end
end
