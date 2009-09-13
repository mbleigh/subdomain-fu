require File.dirname(__FILE__) + '/spec_helper'

describe "SubdomainFu" do
  before do
    SubdomainFu.tld_sizes = SubdomainFu::DEFAULT_TLD_SIZES.dup
    SubdomainFu.mirrors = SubdomainFu::DEFAULT_MIRRORS.dup
    SubdomainFu.preferred_mirror = nil
  end

  describe "TLD Sizes" do
    before do
      SubdomainFu.tld_sizes = SubdomainFu::DEFAULT_TLD_SIZES.dup
    end

    it { SubdomainFu.tld_sizes.should be_kind_of(Hash) }

    it "should have default values for development, test, and production" do
      SubdomainFu.tld_sizes[:development].should == 0
      SubdomainFu.tld_sizes[:test].should        == 0
      SubdomainFu.tld_sizes[:production].should  == 1
    end

    it "#tld_size should be for the current environment" do
      SubdomainFu.tld_size.should == SubdomainFu.tld_sizes[RAILS_ENV.to_sym]
    end

    it "should be able to be set for the current environment" do
      SubdomainFu.tld_size = 5
      SubdomainFu.tld_size.should == 5
      SubdomainFu.tld_sizes[:test].should == 5
    end
  end

  describe "#has_subdomain?" do
    it "should be true for non-mirrored subdomains" do
      SubdomainFu.has_subdomain?("awesome").should be_true
    end

    it "should be false for mirrored subdomains" do
      SubdomainFu.has_subdomain?(SubdomainFu.mirrors.first).should be_false
    end

    it "shoud be false for a nil or blank subdomain" do
      SubdomainFu.has_subdomain?("").should be_false
      SubdomainFu.has_subdomain?(nil).should be_false
      SubdomainFu.has_subdomain?(false).should be_false
    end
  end

  describe "#subdomain_from" do
    it "should return the subdomain based on the TLD of the current environment" do
      SubdomainFu.subdomain_from("awesome.localhost").should == "awesome"
      SubdomainFu.tld_size = 2
      SubdomainFu.subdomain_from("awesome.localhost.co.uk").should == "awesome"
      SubdomainFu.tld_size = 1
      SubdomainFu.subdomain_from("awesome.localhost.com").should == "awesome"
      SubdomainFu.tld_size = 0
    end

    it "should join deep subdomains with a period" do
      SubdomainFu.subdomain_from("awesome.coolguy.localhost").should == "awesome.coolguy"
    end

    it "should return nil for no subdomain" do
      SubdomainFu.subdomain_from("localhost").should be_nil
    end
  end

  it "#host_without_subdomain should chop of the subdomain and return the rest" do
    SubdomainFu.host_without_subdomain("awesome.localhost:3000").should == "localhost:3000"
    SubdomainFu.host_without_subdomain("something.awful.localhost:3000").should == "localhost:3000"
  end

  describe "#preferred_mirror?" do
    describe "when preferred_mirror is false" do
      before do
        SubdomainFu.preferred_mirror = false
      end

      it "should return true for false" do
        SubdomainFu.preferred_mirror?(false).should be_true
      end
    end
  end

  describe "#rewrite_host_for_subdomains" do
    it "should not change the same subdomain" do
      SubdomainFu.rewrite_host_for_subdomains("awesome","awesome.localhost").should == "awesome.localhost"
    end

    it "should not change an equivalent (mirrored) subdomain" do
      SubdomainFu.rewrite_host_for_subdomains("www","localhost").should == "localhost"
    end

    it "should change the subdomain if it's different" do
      SubdomainFu.rewrite_host_for_subdomains("cool","www.localhost").should == "cool.localhost"
    end

    it "should remove the subdomain if passed false when it's not a mirror" do
      SubdomainFu.rewrite_host_for_subdomains(false,"cool.localhost").should == "localhost"
    end

    it "should not remove the subdomain if passed false when it is a mirror" do
      SubdomainFu.rewrite_host_for_subdomains(false,"www.localhost").should == "www.localhost"
    end

    it "should not remove the subdomain if passed nil when it's not a mirror" do
      SubdomainFu.rewrite_host_for_subdomains(nil,"cool.localhost").should == "cool.localhost"
    end

    describe "when preferred_mirror is false" do
      before do
        SubdomainFu.preferred_mirror = false
      end

      it "should remove the subdomain if passed false when it is a mirror" do
        SubdomainFu.rewrite_host_for_subdomains(false,"www.localhost").should == "localhost"
      end

      it "should not remove the subdomain if passed nil when it's not a mirror" do
        SubdomainFu.rewrite_host_for_subdomains(nil,"cool.localhost").should == "cool.localhost"
      end
    end
  end

  describe "#change_subdomain_of_host" do
    it "should change it if passed a different one" do
      SubdomainFu.change_subdomain_of_host("awesome","cool.localhost").should == "awesome.localhost"
    end

    it "should remove it if passed nil" do
      SubdomainFu.change_subdomain_of_host(nil,"cool.localhost").should == "localhost"
    end

    it "should add it if there isn't one" do
      SubdomainFu.change_subdomain_of_host("awesome","localhost").should == "awesome.localhost"
    end
  end

  describe "#current_subdomain" do
    it "should return the current subdomain if there is one" do
      request = mock("request", :subdomains => ["awesome"])
      SubdomainFu.current_subdomain(request).should == "awesome"
    end

    it "should return nil if there's no subdomain" do
      request = mock("request", :subdomains => [])
      SubdomainFu.current_subdomain(request).should be_nil
    end

    it "should return nil if the current subdomain is a mirror" do
      request = mock("request", :subdomains => ["www"])
      SubdomainFu.current_subdomain(request).should be_nil
    end

    it "should return the whole thing (including a .) if there's multiple subdomains" do
      request = mock("request", :subdomains => ["awesome","rad"])
      SubdomainFu.current_subdomain(request).should == "awesome.rad"
    end
  end

  describe "#current_domain" do
    it "should return the current domain if there is one" do
      request = mock("request", :subdomains => [], :domain => "example.com", :port_string => "")
      SubdomainFu.current_domain(request).should == "example.com"
    end

    it "should return empty string if there is no domain" do
      request = mock("request", :subdomains => [], :domain => "", :port_string => "")
      SubdomainFu.current_domain(request).should == ""
    end

    it "should return the current domain if there is only one level of subdomains" do
      request = mock("request", :subdomains => ["www"], :domain => "example.com", :port_string => "")
      SubdomainFu.current_domain(request).should == "example.com"
    end

    it "should return everything but the first level of subdomain when there are multiple levels of subdomains" do
      request = mock("request", :subdomains => ["awesome","rad","cheese","chevy","ford"], :domain => "example.com", :port_string => "")
      SubdomainFu.current_domain(request).should == "rad.cheese.chevy.ford.example.com"
    end

    it "should return the domain with port if port is given" do
      request = mock("request", :subdomains => ["awesome","rad","cheese","chevy","ford"], :domain => "example.com", :port_string => ":3000")
      SubdomainFu.current_domain(request).should == "rad.cheese.chevy.ford.example.com:3000"
    end
  end

  describe "#same_subdomain?" do
    it { SubdomainFu.same_subdomain?("www","www.localhost").should be_true }
    it { SubdomainFu.same_subdomain?("www","localhost").should be_true }
    it { SubdomainFu.same_subdomain?("awesome","www.localhost").should be_false }
    it { SubdomainFu.same_subdomain?("cool","awesome.localhost").should be_false }
    it { SubdomainFu.same_subdomain?(nil,"www.localhost").should be_true }
    it { SubdomainFu.same_subdomain?("www","awesome.localhost").should be_false }
  end

  describe "#needs_rewrite?" do
    it { SubdomainFu.needs_rewrite?("www","www.localhost").should be_false }
    it { SubdomainFu.needs_rewrite?("www","localhost").should be_false }
    it { SubdomainFu.needs_rewrite?("awesome","www.localhost").should be_true }
    it { SubdomainFu.needs_rewrite?("cool","awesome.localhost").should be_true }
    it { SubdomainFu.needs_rewrite?(nil,"www.localhost").should be_false }
    it { SubdomainFu.needs_rewrite?(nil,"awesome.localhost").should be_false }
    it { SubdomainFu.needs_rewrite?(false,"awesome.localhost").should be_true }
    it { SubdomainFu.needs_rewrite?(false,"www.localhost").should be_false }
    it { SubdomainFu.needs_rewrite?("www","awesome.localhost").should be_true }

    describe "when preferred_mirror is false" do
      before do
        SubdomainFu.preferred_mirror = false
      end

      it { SubdomainFu.needs_rewrite?("www","www.localhost").should be_false }
      it { SubdomainFu.needs_rewrite?("www","localhost").should be_false }
      it { SubdomainFu.needs_rewrite?("awesome","www.localhost").should be_true }
      it { SubdomainFu.needs_rewrite?("cool","awesome.localhost").should be_true }
      it { SubdomainFu.needs_rewrite?(nil,"www.localhost").should be_false }
      it { SubdomainFu.needs_rewrite?(nil,"awesome.localhost").should be_false }
      it { SubdomainFu.needs_rewrite?(false,"awesome.localhost").should be_true }
      #Only one different from default set of tests
      it { SubdomainFu.needs_rewrite?(false,"www.localhost").should be_true }
      it { SubdomainFu.needs_rewrite?("www","awesome.localhost").should be_true }
    end

    describe "when preferred_mirror is string" do
      before do
        SubdomainFu.preferred_mirror = "www"
      end

      it { SubdomainFu.needs_rewrite?("www","www.localhost").should be_false }
      it { SubdomainFu.needs_rewrite?("awesome","www.localhost").should be_true }
      # Following is different from default set of tests
      it { SubdomainFu.needs_rewrite?("www","localhost").should be_true }
      it { SubdomainFu.needs_rewrite?("cool","awesome.localhost").should be_true }
      it { SubdomainFu.needs_rewrite?(nil,"www.localhost").should be_false }
      it { SubdomainFu.needs_rewrite?(nil,"awesome.localhost").should be_false }
      it { SubdomainFu.needs_rewrite?(false,"awesome.localhost").should be_true }
      it { SubdomainFu.needs_rewrite?(false,"www.localhost").should be_false }
      it { SubdomainFu.needs_rewrite?("www","awesome.localhost").should be_true }
    end

  end
end
