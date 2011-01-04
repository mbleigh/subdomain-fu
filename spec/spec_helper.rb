require 'action_controller/railtie'
require 'active_support/core_ext/hash/slice'
require 'rspec'
require 'subdomain-fu'

Rails.env = 'test'

module SubdomainFu
  class TestApplication < Rails::Application
  end
end

SubdomainFu::TestApplication.routes.draw do
  match '/needs_subdomain' => "fu#awesome", :as => 'needs_subdomain'
  match '/no_subdomain' => "fu#lame", :as => 'no_subdomain'
  match '/needs_awesome' => "fu#lame", :as => 'needs_awesome'

  resources :foos do
    resources :bars
  end

  match '/' => "site#home", :constraints => { :subdomain => '' }
  #match '/' => "app#home", :constraints => { :subdomain => true }
  match '/' => "mobile#home", :constraints => { :subdomain => "m" }

  #match '/subdomain_here' => "app#success", :constraints => { :subdomain => true }
  match '/no_subdomain_here' => "site#success", :constraints => { :subdomain => '' }
  match '/m_subdomain_here' => "mobile#success", :constraints => { :subdomain => "m" }
  match '/numbers_only_here' => "numbers#success", :constraints => { :subdomain => /[0-9]+/ }

  match ':controller(/:action(/:id(.:format)))'
end

class Paramed
  def initialize(param)
    @param = param
  end

  def to_param
    @param || "param"
  end
end

include Rails.application.routes.url_helpers