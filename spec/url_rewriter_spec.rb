require File.dirname(__FILE__) + '/spec_helper'

describe "SubdomainFu URL Writing" do
  before do
    SubdomainFu.tld_size = 1
    SubdomainFu.mirrors = SubdomainFu::DEFAULT_MIRRORS.dup
    SubdomainFu.override_only_path = true
    SubdomainFu.preferred_mirror = nil
    default_url_options[:host] = "example.com"
  end

  describe "#url_for" do
    it "should be able to add a subdomain" do
      url_for(:controller => "something", :action => "other", :subdomain => "awesome").should == "http://awesome.example.com/something/other"
    end

    it "should be able to remove a subdomain" do
      url_for(:controller => "something", :action => "other", :subdomain => false, :host => "awesome.example.com").should == "http://example.com/something/other"
    end

    it "should not change a mirrored subdomain" do
      url_for(:controller => "something", :action => "other", :subdomain => false, :host => "www.example.com").should == "http://www.example.com/something/other"
    end

    it "should should not force the full url with :only_path if override_only_path is false (default)" do
      SubdomainFu.override_only_path = false
      url_for(:controller => "something", :action => "other", :subdomain => "awesome", :only_path => true).should == "/something/other"
    end

    it "should should force the full url, even with :only_path if override_only_path is true" do
      SubdomainFu.override_only_path = true
      url_for(:controller => "something", :action => "other", :subdomain => "awesome", :only_path => true).should == "http://awesome.example.com/something/other"
    end
  end

  describe "Standard Routes" do
    it "should be able to add a subdomain" do
      needs_subdomain_url(:subdomain => "awesome").should == "http://awesome.example.com/needs_subdomain"
    end

    it "should be able to remove a subdomain" do
      default_url_options[:host] = "awesome.example.com"
      needs_subdomain_url(:subdomain => false).should == "http://example.com/needs_subdomain"
    end

    it "should not change a mirrored subdomain" do
      default_url_options[:host] = "www.example.com"
      needs_subdomain_url(:subdomain => false).should == "http://www.example.com/needs_subdomain"
    end

    it "should should force the full url, even with _path" do
      needs_subdomain_path(:subdomain => "awesome").should == needs_subdomain_url(:subdomain => "awesome")
    end

    it "should not force the full url if it's the same as the current subdomain" do
      default_url_options[:host] = "awesome.example.com"
      needs_subdomain_path(:subdomain => "awesome").should == "/needs_subdomain"
    end

    it "should force the full url if it's a different subdomain" do
      default_url_options[:host] = "awesome.example.com"
      needs_subdomain_path(:subdomain => "crazy").should == "http://crazy.example.com/needs_subdomain"
    end

    it "should not force the full url if the current subdomain is nil and so is the target" do
      needs_subdomain_path(:subdomain => nil).should == "/needs_subdomain"
    end

    it "should not force the full url if no :subdomain option is given" do
      needs_subdomain_path.should == "/needs_subdomain"
      default_url_options[:host] = "awesome.example.com"
      needs_subdomain_path.should == "/needs_subdomain"
    end
  end

  describe "Resourced Routes" do
    it "should be able to add a subdomain" do
      foo_path(:id => "something", :subdomain => "awesome").should == "http://awesome.example.com/foos/something"
    end

    it "should be able to remove a subdomain" do
      default_url_options[:host] = "awesome.example.com"
      foo_path(:id => "something", :subdomain => false).should == "http://example.com/foos/something"
    end

    it "should work when passed in a paramable object" do
      foo_path(Paramed.new("something"), :subdomain => "awesome").should == "http://awesome.example.com/foos/something"
    end

    it "should work when passed in a paramable object" do
      foo_path(Paramed.new("something"), :subdomain => "awesome").should == "http://awesome.example.com/foos/something"
    end

    it "should work when passed in a paramable object and no subdomain to a _path" do
      default_url_options[:host] = "awesome.example.com"
      foo_path(Paramed.new("something")).should == "/foos/something"
    end

    it "should work when passed in a paramable object and no subdomain to a _url" do
      default_url_options[:host] = "awesome.example.com"
      foo_url(Paramed.new("something")).should == "http://awesome.example.com/foos/something"
    end

    it "should work on nested resource collections" do
      foo_bars_path(Paramed.new("something"), :subdomain => "awesome").should == "http://awesome.example.com/foos/something/bars"
    end

    it "should work on nested resource members" do
      foo_bar_path(Paramed.new("something"),Paramed.new("else"), :subdomain => "awesome").should == "http://awesome.example.com/foos/something/bars/else"
    end
  end

  describe "Preferred Mirror" do
    before do
      SubdomainFu.preferred_mirror = "www"
      SubdomainFu.override_only_path = true
    end

    it "should switch to the preferred mirror instead of no subdomain" do
      default_url_options[:host] = "awesome.example.com"
      needs_subdomain_url(:subdomain => false).should == "http://www.example.com/needs_subdomain"
    end

    it "should switch to the preferred mirror automatically" do
      default_url_options[:host] = "example.com"
      needs_subdomain_url.should == "http://www.example.com/needs_subdomain"
    end

    it "should work when passed in a paramable object and no subdomain to a _url" do
      default_url_options[:host] = "awesome.example.com"
      foo_url(Paramed.new("something")).should == "http://awesome.example.com/foos/something"
    end

    it "should force a switch to no subdomain on a mirror if preferred_mirror is false" do
      SubdomainFu.preferred_mirror = false
      default_url_options[:host] = "www.example.com"
      needs_subdomain_url(:subdomain => false).should == "http://example.com/needs_subdomain"
    end

    after do
      SubdomainFu.preferred_mirror = nil
    end
  end

  after do
    SubdomainFu.tld_size = 0
    default_url_options[:host] = "localhost"
  end
end
