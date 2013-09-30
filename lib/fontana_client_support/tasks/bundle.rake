# -*- coding: utf-8 -*-
require 'fontana_client_support'

# http://bundler.io/v1.3/bundle_config.html
namespace :bundle do

  task :unset_env_bundle_environments do
    targets = ENV.keys.select{|k| k =~ /\ABUNDLE_/}
    targets.each{|t| ENV.delete(t) }
  end

  task :unset_env_gem_home do
    ENV.delete("GEM_HOME")
  end

  task :unset_env => [:unset_env_bundle_environments, :unset_env_gem_home]

end
