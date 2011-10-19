require 'subdomain_fu/url_rewriter'
require 'subdomain_fu/subdomain_fu'
require 'subdomain_fu/engine'
#
#module SubdomainFu
#  class << self
#    attr_accessor :config
#
#    def config
#      self.config = Configuration.new unless @config
#      @config
#    end
#  end
#
#  # The configurable options of Subdomain Fu. Use like so:
#  #
#  #     SubdomainFu.configure do |config|
#  #       config.tld_size = 2
#  #       config.preferred_mirror = 'www'
#  #     end
#  #
#  # Available configurations are:
#  #
#  # <tt>tld_size</tt>: :: The size of the top-level domain. For example, 'localhost' is 0, 'example.com' is 1, and 'example.co.uk' is 2.
#  # <tt>mirrors</tt>: :: An array of subdomains that should be equivalent to no subdomain. Defaults to <tt>['www']</tt>.
#  # <tt>preferred_mirror</tt>: The preferred mirror subdomain to which to rewrite URLs. No subdomain is used by default.
#  # <tt>override_only_path</tt>: :: If <tt>true</tt>, changing the subdomain will emit a full URL in url_for options, even if it wouldn't have otherwise.
#  def self.configure
#    self.config ||= Configuration.new
#    yield(self.config)
#  end
#
#  class Configuration
#    attr_accessor :tld_sizes, :mirrors, :preferred_mirror, :override_only_path
#
#    @@defaults = {
#      :tld_sizes => {:development => 1, :test => 1, :production => 1},
#      :mirrors => %w(www),
#      :preferred_mirror => nil,
#      :override_only_path => false
#    }
#
#    def initialize
#      @@defaults.each_pair do |k, v|
#        self.send("#{k}=", v)
#      end
#    end
#
#    def tld_size=(size)
#      tld_sizes[Rails.env.to_sym] = size
#    end
#
#    def tld_size
#      tld_sizes[Rails.env.to_sym]
#    end
#  end
#
#  def self.has_domain?(host)
#    !host.blank? && !(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/.match(host))
#  end
#
#  # Is the current subdomain either nil or not a mirror?
#  def self.has_subdomain?(subdomain)
#    subdomain != false && !subdomain.blank? && !SubdomainFu.config.mirrors.include?(subdomain)
#  end
#
#  def self.is_mirror?(subdomain)
#    subdomain != false && !subdomain.blank? && SubdomainFu.config.mirrors.include?(subdomain)
#  end
#
#  # Is the subdomain a preferred mirror
#  def self.preferred_mirror?(subdomain)
#    subdomain == SubdomainFu.config.preferred_mirror || SubdomainFu.config.preferred_mirror.nil?
#  end
#
#  # Gets the subdomain from the host based on the TLD size
#  def self.subdomain_from(host)
#    return nil unless has_domain?(host)
#    parts = host.split('.')
#    sub = parts[0..-(SubdomainFu.config.tld_size+2)].join(".")
#    sub.blank? ? nil : sub
#  end
#
#  # Gets only non-mirror subdomains from the host based on the TLD size
#  def self.non_mirror_subdomain_from(host)
#    sub = subdomain_from(host)
#    has_subdomain?(sub) ? sub : nil
#  end
#
#  def self.host_without_subdomain(host)
#    parts = host.split('.')
#    parts[-(SubdomainFu.config.tld_size+1)..-1].join(".")
#  end
#
#  # Rewrites the subdomain of the host unless they are equivalent (i.e. mirrors of each other)
#  def self.rewrite_host_for_subdomains(subdomain, host)
#    if needs_rewrite?(subdomain, host)
#      change_subdomain_of_host(subdomain || SubdomainFu.config.preferred_mirror, host)
#    else
#      if has_subdomain?(subdomain) || preferred_mirror?(subdomain_from(host)) ||
#          (subdomain.nil? && has_subdomain?(subdomain_from(host)))
#        host
#      else
#        change_subdomain_of_host(SubdomainFu.config.preferred_mirror, host)
#      end
#    end
#  end
#
#  # Changes the subdomain of the host to whatever is passed in.
#  def self.change_subdomain_of_host(subdomain, host)
#    host = SubdomainFu.host_without_subdomain(host)
#    host = "#{subdomain}.#{host}" if subdomain
#    host
#  end
#
#  # Is this subdomain equivalent to the subdomain found in this host string?
#  def self.same_subdomain?(subdomain, host)
#    subdomain = nil unless subdomain
#    (subdomain == subdomain_from(host)) ||
#      (!has_subdomain?(subdomain) && !has_subdomain?(subdomain_from(host)))
#  end
#
#  # Is the host without subdomain equivalent to the subdomain_host in this subdomain_host string?
#  def self.same_host?(subdomain_host, host)
#    SubdomainFu.host_without_subdomain(host) == subdomain_host
#  end
#
#  def self.override_only_path?
#    config.override_only_path
#  end
#
#  def self.needs_rewrite?(subdomain, host)
#    case subdomain
#      when nil
#        #rewrite when there is a preferred mirror set and there is no subdomain on the host
#        return true if config.preferred_mirror && subdomain_from(host).nil?
#        return false
#      when false
#        h = subdomain_from(host)
#        #if the host has a subdomain
#        if !h.nil?
#          #rewrite when there is a subdomain in the host, and it is not a preferred mirror
#          return true if !preferred_mirror?(h)
#          #rewrite when there is a preferred mirror set and the subdomain of the host is not a mirror
#          return true if config.preferred_mirror && !is_mirror?(h)
#          #no rewrite if host already has mirror subdomain
#          #it { SubdomainFu.needs_rewrite?(false,"www.localhost").should be_false }
#          return false if is_mirror?(h)
#        end
#        return self.crazy_rewrite_rule(subdomain, host)
#      else
#        return self.crazy_rewrite_rule(subdomain, host)
#    end
#  end
#
#  #This is a black box of crazy!  So I split some of the simpler logic out into the case statement above to make my brain happy!
#  def self.crazy_rewrite_rule(subdomain, host)
#    (!has_subdomain?(subdomain) && preferred_mirror?(subdomain) && !preferred_mirror?(subdomain_from(host))) ||
#      !same_subdomain?(subdomain, host)
#  end
#
#  #returns nil or the subdomain(s)
#  def self.current_subdomain(request)
#    subdomain = request.subdomains(SubdomainFu.config.tld_size).join(".")
#    if has_subdomain?(subdomain)
#      subdomain
#    else
#      nil
#    end
#  end
#
#  #returns nil or the domain or ip
#  #Enables subdomain-fu to more completely replace DHH's account_location plugin
#  def self.current_domain(request)
#    return request.domain unless has_domain?(request.domain)
#    domain = ""
#    domain << request.subdomains[1..-1].join(".") + "." if request.subdomains.length > 1
#    domain << request.domain + request.port_string
#  end
#
#  module Controller
#    def self.included(controller)
#      controller.helper_method(:current_subdomain)
#      controller.helper_method(:current_domain)
#    end
#
#    protected
#    def current_subdomain
#      SubdomainFu.current_subdomain(request)
#    end
#    def current_domain
#      SubdomainFu.current_domain(request)
#    end
#  end
#end
#
#require 'subdomain_fu/rails'
