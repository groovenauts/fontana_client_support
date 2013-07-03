require 'fontana_client_support'
include Fontana::ServerRake

namespace_with_fontana :server, :libgss_test do
  fontana_task :launch_http_server

  fontana_task :launch_http_server_daemon

  fontana_task :launch_https_server

  fontana_task :launch_https_server_daemon

  desc "luanch server daemons"
  fontana_task :launch_server_daemons

  desc "shutdown server daemons"
  fontana_task :shutdown_server_daemons

  desc "check daemon alive"
  fontana_task :check_daemon_alive
end
