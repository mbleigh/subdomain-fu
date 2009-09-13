require 'subdomain_fu/routing_extensions'
require 'subdomain_fu/url_rewriter'

module SubdomainFu
  # The length of the period-split top-level domain for each environment.
  # For example, "localhost" has a tld_size of zero, and "something.co.uk"
  # has a tld_size of two.
  #
  # To set a tld size for a given environment, just call SubdomainFu.tld_sizes[:environment] = value
  DEFAULT_TLD_SIZES = {:development => 0, :test => 0, :production => 1}
  mattr_accessor :tld_sizes
  @@tld_sizes = DEFAULT_TLD_SIZES.dup

  # Subdomains that are equivalent to going to the website with no subdomain at all.
  # Defaults to "www" as the only member.
  DEFAULT_MIRRORS = %w(www)
  mattr_accessor :mirrors
  @@mirrors = DEFAULT_MIRRORS.dup

  mattr_accessor :preferred_mirror
  @@preferred_mirror = nil

  mattr_accessor :override_only_path
  @@override_only_path = false

  # Returns the TLD Size of the current environment.
  def self.tld_size
    tld_sizes[RAILS_ENV.to_sym]
  end

  # Sets the TLD Size of the current environment
  def self.tld_size=(value)
    tld_sizes[RAILS_ENV.to_sym] = value
  end

  # Is the current subdomain either nil or not a mirror?
  def self.has_subdomain?(subdomain)
    subdomain != false && !subdomain.blank? && !SubdomainFu.mirrors.include?(subdomain)
  end

  def self.is_mirror?(subdomain)
    subdomain != false && !subdomain.blank? && SubdomainFu.mirrors.include?(subdomain)
  end

  # Is the subdomain a preferred mirror
  def self.preferred_mirror?(subdomain)
    subdomain == SubdomainFu.preferred_mirror || SubdomainFu.preferred_mirror.nil?
  end

  # Gets the subdomain from the host based on the TLD size
  def self.subdomain_from(host)
    return nil if host.nil? || /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/.match(host)
    parts = host.split('.')
    sub = parts[0..-(SubdomainFu.tld_size+2)].join(".")
    sub.blank? ? nil : sub
  end

  # Gets only non-mirror subdomains from the host based on the TLD size
  def self.non_mirror_subdomain_from(host)
    sub = subdomain_from(host)
    has_subdomain?(sub) ? sub : nil
  end

  def self.host_without_subdomain(host)
    parts = host.split('.')
    parts[-(SubdomainFu.tld_size+1)..-1].join(".")
  end

  # Rewrites the subdomain of the host unless they are equivalent (i.e. mirrors of each other)
  def self.rewrite_host_for_subdomains(subdomain, host)
    if needs_rewrite?(subdomain, host)
      change_subdomain_of_host(subdomain || SubdomainFu.preferred_mirror, host)
    else
      if has_subdomain?(subdomain) || preferred_mirror?(subdomain_from(host)) ||
          (subdomain.nil? && has_subdomain?(subdomain_from(host)))
        host
      else
        change_subdomain_of_host(SubdomainFu.preferred_mirror, host)
      end
    end
  end

  # Changes the subdomain of the host to whatever is passed in.
  def self.change_subdomain_of_host(subdomain, host)
    host = SubdomainFu.host_without_subdomain(host)
    host = "#{subdomain}.#{host}" if subdomain
    host
  end

  # Is this subdomain equivalent to the subdomain found in this host string?
  def self.same_subdomain?(subdomain, host)
    subdomain = nil unless subdomain
    (subdomain == subdomain_from(host)) ||
      (!has_subdomain?(subdomain) && !has_subdomain?(subdomain_from(host)))
  end

  def self.override_only_path?
    self.override_only_path
  end

  def self.needs_rewrite?(subdomain, host)
    case subdomain
      when nil
        #rewrite when there is a preferred mirror set and there is no subdomain on the host
        return true if self.preferred_mirror && subdomain_from(host).nil?
        return false
      when false
        h = subdomain_from(host)
        #if the host has a subdomain
        if !h.nil?
          #rewrite when there is a subdomain in the host, and it is not a preferred mirror
          return true if !preferred_mirror?(h)
          #rewrite when there is a preferred mirror set and the subdomain of the host is not a mirror
          return true if self.preferred_mirror && !is_mirror?(h)
          #no rewrite if host already has mirror subdomain
          #it { SubdomainFu.needs_rewrite?(false,"www.localhost").should be_false }
          return false if is_mirror?(h)
        end
        return self.crazy_rewrite_rule(subdomain, host)
      else
        return self.crazy_rewrite_rule(subdomain, host)
    end
  end

  #This is a black box of crazy!  So I split some of the simpler logic out into the case statement above to make my brain happy!
  def self.crazy_rewrite_rule(subdomain, host)
    (!has_subdomain?(subdomain) && preferred_mirror?(subdomain) && !preferred_mirror?(subdomain_from(host))) ||
      !same_subdomain?(subdomain, host)
  end

  def self.current_subdomain(request)
    subdomain = request.subdomains(SubdomainFu.tld_size).join(".")
    if has_subdomain?(subdomain)
      subdomain
    else
      nil
    end
  end

  #Enables subdomain-fu to more completely replace DHH's account_location plugin
  def self.current_domain(request)
    domain = ""
    domain << request.subdomains[1..-1].join(".") + "." if request.subdomains.length > 1
    domain << request.domain + request.port_string
  end

  module Controller
    def self.included(controller)
      controller.helper_method(:current_subdomain)
      controller.helper_method(:current_domain)
    end

    protected
    def current_subdomain
      SubdomainFu.current_subdomain(request)
    end
    def current_domain
      SubdomainFu.current_domain(request)
    end
  end
end
