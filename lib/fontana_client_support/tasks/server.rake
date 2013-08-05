require 'fontana_client_support'
include Fontana::ServerRake

extend Fontana::RakeUtils

namespace_with_fontana :server, :libgss_test do

  fontana_task :launch_http_server
  fontana_task :launch_http_server_daemon
  fontana_task :launch_https_server
  fontana_task :launch_https_server_daemon
  fontana_task :launch_server_daemons
  fontana_task :shutdown_server_daemons
  fontana_task :check_daemon_alive
end


namespace :servers do
  desc "start HTTP+HTTPS server daemons"
  task :start => :"server:launch_server_daemons"

  desc "stop HTTP+HTTPS server daemons"
  task :stop => :"server:shutdown_server_daemons"

  desc "restart HTTP+HTTPS server daemons"
  task_sequential(:restart, [:"servers:stop", :"servers:start"])
end
