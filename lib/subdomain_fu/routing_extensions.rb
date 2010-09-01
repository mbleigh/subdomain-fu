# Thanks to Jamis Buck for ideas on this stuff
# http://weblog.jamisbuck.org/2006/10/26/monkey-patching-rails-extending-routes-2
# This is not yet a working part of SubdomainFu.

module SubdomainFu
  module RouteExtensions
    def self.included(base)
      base.alias_method_chain :recognition_conditions, :subdomain
    end

    def recognition_conditions_with_subdomain
      result = recognition_conditions_without_subdomain
      result << "conditions[:subdomain] === env[:subdomain]" if conditions[:subdomain] && conditions[:subdomain] != true && conditions[:subdomain] != false
      result << "SubdomainFu.has_subdomain?(env[:subdomain])" if conditions[:subdomain] == true
      result << "!SubdomainFu.has_subdomain?(env[:subdomain])" if conditions[:subdomain] == false
      result
    end
  end

  module RouteSetExtensions
    def self.included(base)
      base.alias_method_chain :extract_request_environment, :subdomain
    end

    def extract_request_environment_with_subdomain(request)
      env = extract_request_environment_without_subdomain(request)
      env.merge(:host => request.host, :domain => request.domain, :subdomain => SubdomainFu.current_subdomain(request))
    end
  end

  module MapperExtensions
    def quick_map(has_unless, *args, &block)
      options = args.find{|a| a.is_a?(Hash)}
      namespace_str = options ? options.delete(:namespace).to_s : args.join('_or_')
      namespace_str += '_' unless namespace_str.blank?
      mapped_exp = args.map(&:to_s).join('|')
      conditions_hash = { :subdomain => ( has_unless ? /[^(#{mapped_exp})]/ : /(#{mapped_exp})/) }
      with_options(:conditions => conditions_hash, :name_prefix => namespace_str, &block)
    end
    # Adds methods to Mapper to apply an options with a method. Example
    #   map.subdomain :blog { |blog| blog.resources :pages }
    # or
    #   map.unless_subdomain :blog { |not_blog| not_blog.resources :people }
    def subdomain(*args, &block)
      quick_map(false, *args, &block)
    end
    def unless_subdomain(*args, &block)
      quick_map(true, *args, &block)
    end
  end
end

ActionController::Routing::RouteSet::Mapper.send :include, SubdomainFu::MapperExtensions
ActionController::Routing::RouteSet.send :include, SubdomainFu::RouteSetExtensions
ActionController::Routing::Route.send :include, SubdomainFu::RouteExtensions

# UrlRewriter::RESERVED_OPTIONS is only available in Rails >= 2.2
# http://www.portallabs.com/blog/2008/12/02/fixing-subdomain_fu-with-named-routes-rails-22/
if Rails::VERSION::MAJOR >= 2 and Rails::VERSION::MINOR >= 2
  ActionController::UrlRewriter::RESERVED_OPTIONS << :subdomain
end
