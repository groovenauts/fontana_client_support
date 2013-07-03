require 'fontana_client_support'

require "rspec/core/rake_task"

Dir[File.expand_path("../tasks/**/*.rake", __FILE__)].each{|f| load(f)}
