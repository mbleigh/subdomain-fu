# I use this to make life easier when installing and testing from source:
rm -rf subdomain-fu-*.gem && gem build subdomain-fu.gemspec && sudo gem uninstall subdomain-fu && sudo gem install subdomain-fu-0.5.2.gem --no-ri --no-rdoc
