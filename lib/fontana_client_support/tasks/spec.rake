# -*- coding: utf-8 -*-
require 'fontana_client_support'
include Fontana::ServerRake

desc "Run RSpec with server_daemons"
task :spec_with_server_daemons => [:"vendor:fontana:prepare"] do
  Rake::Task["server:launch_server_daemons"].execute
  begin
    sleep( (ENV["FONTANA_LAUNCH_SLEEP"] || 5).to_i ) # 実際にポートをLINSTENするまで待つ
    Rake::Task["spec"].execute
  ensure
    Rake::Task["server:shutdown_server_daemons"].execute
  end
end
