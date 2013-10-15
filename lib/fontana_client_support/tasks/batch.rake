# -*- coding: utf-8 -*-
require 'fontana_client_support'

include Fontana::CommandUtils
extend Fontana::RakeUtils

namespace :batch do

  desc "run batch file with FILE=app/batch/xxxx.rb"
  task :run do
    path = File.expand_path(ENV['FILE'], FontanaClientSupport.root_dir)
    system_at_vendor_fontana!("bundle exec rails r #{path}")
  end

end
