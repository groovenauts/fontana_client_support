require 'fileutils'

require 'fontana_client_support'
extend Fontana::RakeUtils

namespace :config_server do

  desc "launch server process in foreground mode"
  task :launch do
    FontanaClientSupport::ConfigServer.new.launch
  end

  desc "start server daemon"
  task :start do
    FontanaClientSupport::ConfigServer.start_daemon
  end

  desc "stop server daemon"
  task :stop do
    FontanaClientSupport::ConfigServer.stop_daemon
  end

  desc "stop and start server daemon"
  task_sequential(:restart, [:"config_server:stop", :"config_server:start"])
end
