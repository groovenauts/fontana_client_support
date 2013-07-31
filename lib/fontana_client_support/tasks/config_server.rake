require 'fileutils'

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

end
