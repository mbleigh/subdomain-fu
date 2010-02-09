require 'action_controller/metal/url_for'
require 'action_controller/url_rewriter'

module ActionController
  # module UrlFor
  #   def url_for_with_subdomains(options)
  #     if SubdomainFu.needs_rewrite?(options[:subdomain], options[:host] || default_url_options[:host]) || options[:only_path] == false
  #       options[:only_path] = false if SubdomainFu.override_only_path?
  #       options[:host] = SubdomainFu.rewrite_host_for_subdomains(options.delete(:subdomain), options[:host] || default_url_options[:host])
  #     else
  #       options.delete(:subdomain)
  #     end
  #     url_for_without_subdomains(options)
  #   end
  #   alias_method_chain :url_for, :subdomains
  # end

  class UrlRewriter #:nodoc:
    class << self
      def rewrite_with_subdomains(options, path_segments=nil)
        if SubdomainFu.needs_rewrite?(options[:subdomain], (options[:host] || @request.host_with_port)) || options[:only_path] == false
          options[:only_path] = false if SubdomainFu.override_only_path?
          options[:host] = SubdomainFu.rewrite_host_for_subdomains(options.delete(:subdomain), options[:host] || @request.host_with_port)
          # puts "options[:host]: #{options[:host].inspect}"
        else
          options.delete(:subdomain)
        end
        rewrite_without_subdomains(options, path_segments)
      end
      alias_method_chain :rewrite, :subdomains
    end
  end
end
