require 'subdomain_fu/routing_extensions'

module SubdomainFu
  # The length of the period-split top-level domain for each environment.
  # For example, "localhost" has a tld_size of zero, and "something.co.uk"
  # has a tld_size of two.
  #
  # To set a tld size for a given environment, just call SubdomainFu.tld_sizes[:environment] = value
  mattr_accessor :tld_sizes
  @@tld_sizes = {:development => 0, :test => 0, :production => 1}
  
  # Subdomains that are equivalent to going to the website with no subdomain at all.
  # Defaults to "www" as the only member.
  mattr_accessor :mirrors
  @@mirrors = %w(www)
  
  mattr_accessor :preferred_mirror
  @@preferred_mirror = nil
  
  # Returns the TLD Size of the current environment.
  def self.tld_size
    tld_sizes[RAILS_ENV.to_sym]
  end
  
  def self.tld_size=(value)
    tld_sizes[RAILS_ENV.to_sym] = value
  end
  
  def self.has_subdomain?(subdomain)
    subdomain && !SubdomainFu.mirrors.include?(subdomain)
  end
  
  def self.subdomain_from(host)
    return nil unless host
    parts = host.split('.')
    parts[0..-(SubdomainFu.tld_size+2)].join(".")
  end
  
  def self.host_without_subdomain(host)
    parts = host.split('.')
    parts[-(SubdomainFu.tld_size+1)..-1].join(".")
  end
  
  def self.rewrite_host_for_subdomains(subdomain, host)
    if same_subdomain?(subdomain, host)
      host
    else
      change_subdomain_of_host(subdomain, host)
    end
  end
  
  def self.change_subdomain_of_host(subdomain, host)
    host = SubdomainFu.host_without_subdomain(host)
    host = "#{subdomain}.#{host}" if subdomain
    host
  end
  
  def self.same_subdomain?(subdomain, host)
    result = subdomain == SubdomainFu.subdomain_from(host) || 
      (!SubdomainFu.has_subdomain?(subdomain) && !SubdomainFu.has_subdomain?(SubdomainFu.subdomain_from(host)))
    result
  end
  
  module Controller
    def self.included(controller)
      controller.helper_method(:current_subdomain, :current_subdomain)
    end
    
    protected
    
    def current_subdomain
      request.subdomains(SubdomainFu.tld_size).join(".")
    end
  end
end