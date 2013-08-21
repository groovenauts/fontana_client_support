# -*- coding: utf-8 -*-
require 'fontana_client_support'

desc "Run RSpec with server_daemons"
task :spec_with_server_daemons => [:"vendor:fontana:prepare"] do
  Fontana.app_mode, app_mode_backup = "test", Fontana.app_mode
  Rake::Task["server:launch_server_daemons"].execute
  sleep( (ENV["FONTANA_LAUNCH_SLEEP"] || 5).to_i ) # 実際にポートをLINSTENするまで待つ
  at_exit do
    Rake::Task["server:shutdown_server_daemons"].execute
    Fontana.app_mode = app_mode_backup
  end
  Rake::Task["spec"].execute
end
