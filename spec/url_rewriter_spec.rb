require File.dirname(__FILE__) + '/spec_helper'

describe "SubdomainFu URL Writing" do
  before do
    SubdomainFu.tld_size = 1
  end
  
  describe "#url_for" do
    it "should be able to add a subdomain" do
      url_for(:controller => "something", :action => "other", :subdomain => "awesome").should == "http://awesome.testapp.com/something/other" 
    end
  
    it "should be able to remove a subdomain" do
      url_for(:controller => "something", :action => "other", :subdomain => false, :host => "awesome.testapp.com").should == "http://testapp.com/something/other" 
    end
    
    it "should not change a mirrored subdomain" do
      url_for(:controller => "something", :action => "other", :subdomain => false, :host => "www.testapp.com").should == "http://www.testapp.com/something/other" 
    end
    
    it "should should force the full url, even with :only_path" do
      url_for(:controller => "something", :action => "other", :subdomain => "awesome", :only_path => true).should == "http://awesome.testapp.com/something/other" 
    end
  end
  
  describe "Standard Routes" do
    it "should be able to add a subdomain" do
      needs_subdomain_url(:subdomain => "awesome").should == "http://awesome.testapp.com/needs_subdomain"
    end

    it "should be able to remove a subdomain" do
      default_url_options[:host] = "awesome.testapp.com"
      needs_subdomain_url(:subdomain => false).should == "http://testapp.com/needs_subdomain"
    end

    it "should not change a mirrored subdomain" do
      default_url_options[:host] = "www.testapp.com"
      needs_subdomain_url(:subdomain => false).should == "http://www.testapp.com/needs_subdomain"
    end

    it "should should force the full url, even with _path" do
      needs_subdomain_path(:subdomain => "awesome").should == needs_subdomain_url(:subdomain => "awesome")
    end
  end
  
  after do
    SubdomainFu.tld_size = 0
    default_url_options[:host] = "testapp.com"
  end
end