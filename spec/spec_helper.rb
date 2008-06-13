begin
  require File.dirname(__FILE__) + '/../../../../spec/spec_helper'
rescue LoadError
  puts "You need to install rspec in your base app"
  exit
end

plugin_spec_dir = File.dirname(__FILE__)
ActiveRecord::Base.logger = Logger.new(plugin_spec_dir + "/debug.log")

ActionController::Routing::Routes.draw do |map|
  map.needs_subdomain '/needs_subdomain', :controller => "fu", :action => "awesome", :conditions => {:subdomain => true}
  map.resources :fu_somethings, :conditions => {:subdomain => true}
  map.connect '/:controller/:action/:id'
end


include ActionController::UrlWriter
default_url_options[:host] = "testapp.com"