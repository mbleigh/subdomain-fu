# Thanks to Jamis Buck for ideas on this stuff
# http://weblog.jamisbuck.org/2006/10/26/monkey-patching-rails-extending-routes-2
module SubdomainFu
  module RouteExtensions
    def self.included(base)
      base.alias_method_chain :recognition_conditions, :subdomain
    end

    def recognition_conditions_with_subdomain
      result = recognition_conditions_without_subdomain
      result << "conditions[:subdomain] === env[:subdomain]" if conditions[:subdomain] && conditions[:subdomain] != true
      result << "SubdomainFu.has_subdomain?(env[:subdomain])" if conditions[:subdomain] == true
      result
    end
  end
  
  module RouteSetExtensions
    def self.included(base)
      base.alias_method_chain :extract_request_environment, :subdomain      
    end

    def extract_request_environment_with_subdomain(request)
      env = extract_request_environment_without_subdomain(request)
      env.merge(:host => request.host, :domain => request.domain, :subdomain => SubdomainFu.subdomain_from(request.host))
    end
  end
end