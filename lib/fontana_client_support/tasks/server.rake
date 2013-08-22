# -*- coding: utf-8 -*-
require 'fontana_client_support'

include Fontana::CommandUtils
extend Fontana::RakeUtils

namespace :server do

  pid_dir = File.join(FontanaClientSupport.root_dir, "tmp/pids")

  common_cmd = "BUNDLE_GEMFILE=Gemfile-LibgssTest bundle exec"

  desc "luanch HTTP server"
  task( :launch_http_server       ){ system_at_root!("#{common_cmd} rails server -p #{ENV['HTTP_PORT'] || 3000}") }

  desc "luanch HTTP server daemon"
  task(:launch_http_server_daemon ){ system_at_root!("#{common_cmd} rails server -p #{ENV['HTTP_PORT'] || 3000} -d -P #{pid_dir}/http_server.pid") }

  # HTTPSのポートは script/secure_rails の内部で ENV['HTTPS_PORT'] を参照しています
  desc "luanch HTTPS server"
  task(:launch_https_server       ){ system_at_root!("#{common_cmd} script/secure_rails server webrick") }

  desc "luanch HTTPS server daemon"
  task(:launch_https_server_daemon){ system_at_root!("#{common_cmd} script/secure_rails server webrick -d -P #{pid_dir}/https_server.pid") }

  desc "luanch server"
  task :launch_server => :launch_http_server

  desc "luanch server daemons"
  task :launch_server_daemons => [:launch_http_server_daemon, :launch_https_server_daemon]

  desc "shutdown server daemons"
  task :shutdown_server_daemons do
    Dir.glob(File.join(pid_dir, "*.pid")) do |pid_path|
      pid = `cat #{pid_path}`.strip
      system!("kill -INT #{pid}")
    end
  end

  desc "check daemon alive"
  task :check_daemon_alive do
    pids = Dir.glob(File.join(pid_dir, "*.pid")).to_a
    raise "daemons seems to be still alive! #{pids.inspect}" unless pids.empty?
  end

end


namespace :servers do
  desc "start HTTP+HTTPS server daemons"
  task :start => :"server:launch_server_daemons"

  desc "stop HTTP+HTTPS server daemons"
  task :stop => :"server:shutdown_server_daemons"

  desc "restart HTTP+HTTPS server daemons"
  task_sequential(:restart, [:"servers:stop", :"servers:start"])
end
