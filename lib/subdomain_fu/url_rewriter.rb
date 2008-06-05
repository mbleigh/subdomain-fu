module ActionController
  module UrlWriter
    def url_for_with_subdomains(options)
      unless SubdomainFu.same_subdomain?(options[:subdomain], options[:host])
        options[:only_path] = false 
        options[:host] = SubdomainFu.rewrite_host_for_subdomains(options.delete(:subdomain), options[:host])
      end
      url_for_without_subdomains(options)
    end
  end
  
  class UrlRewriter #:nodoc:
    private
    
    def rewrite_url_with_subdomains(options)
      unless SubdomainFu.same_subdomain?(options[:subdomain], (options[:host] || @request.host_with_port))
        options[:only_path] = false
        options[:host] = SubdomainFu.rewrite_host_for_subdomains(options.delete(:subdomain), options[:host] || @request.host_with_port)
      end
      rewrite_url_without_subdomains(options)
    end
    alias_method_chain :rewrite_url, :subdomains
  end
end