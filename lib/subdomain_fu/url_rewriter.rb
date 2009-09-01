module ActionController
  module UrlWriter
    def url_for_with_subdomains(options)
      if SubdomainFu.needs_rewrite?(options[:subdomain], options[:host] || default_url_options[:host]) || options[:only_path] == false
        options[:only_path] = false if SubdomainFu.override_only_path?
        options[:host] = SubdomainFu.rewrite_host_for_subdomains(options.delete(:subdomain), options[:host] || default_url_options[:host])
      else
        options.delete(:subdomain)
      end
      url_for_without_subdomains(options)
    end
    alias_method_chain :url_for, :subdomains
  end

  class UrlRewriter #:nodoc:
    private

    def rewrite_url_with_subdomains(options)
      if SubdomainFu.needs_rewrite?(options[:subdomain], (options[:host] || @request.host_with_port)) || options[:only_path] == false
        options[:only_path] = false if SubdomainFu.override_only_path?
        options[:host] = SubdomainFu.rewrite_host_for_subdomains(options.delete(:subdomain), options[:host] || @request.host_with_port)
        # puts "options[:host]: #{options[:host].inspect}"
      else
        options.delete(:subdomain)
      end
      rewrite_url_without_subdomains(options)
    end
    alias_method_chain :rewrite_url, :subdomains
  end

  if Rails::VERSION::MAJOR >= 2 and Rails::VERSION::MINOR <= 1
    # hack for http://www.portallabs.com/blog/2008/10/22/fixing-subdomain_fu-with-named-routes/
    module Routing
      module Optimisation
        class PositionalArgumentsWithAdditionalParams
          def guard_condition_with_subdomains
            # don't allow optimisation if a subdomain is present - fixes a problem
            # with the subdomain appearing in the query instead of being rewritten
            # see http://mbleigh.lighthouseapp.com/projects/13148/tickets/8-improper-generated-urls-with-named-routes-for-a-singular-resource
            guard_condition_without_subdomains + " && !args.last.has_key?(:subdomain)"
          end

          alias_method_chain :guard_condition, :subdomains
        end
      end
    end
  end
end
