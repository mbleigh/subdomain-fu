module SubdomainFU
  class Engine < ::Rails::Engine
    initializer "setup for rails" do
      ActionController::Base.send :include, SubdomainFu::Controller
    end
  end
end
