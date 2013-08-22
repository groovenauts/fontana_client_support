# -*- coding: utf-8 -*-
require 'fontana_client_support'

include Fontana::CommandUtils
extend Fontana::RakeUtils

{
  development: {http_port: 3000, https_port: 3001 },
  test:        {http_port: 4000, https_port: 4001 },
}.each do |app_mode, config|
  namespace app_mode.to_sym do

    namespace :server do
      pid_dir = File.join(FontanaClientSupport.root_dir, "tmp/pids")

      common_cmd = "BUNDLE_GEMFILE=Gemfile-LibgssTest bundle exec"

      # desc "luanch HTTP server"
      task( :launch_http_server       ){ system_at_root!("#{common_cmd} rails server -p #{config[:http_port]}", "FONTANA_APP_MODE" => app_mode) }

      # desc "luanch HTTP server daemon"
      task(:launch_http_server_daemon ){ system_at_root!("#{common_cmd} rails server -p #{config[:http_port]} -d -P #{pid_dir}/#{app_mode}_http_server.pid", "FONTANA_APP_MODE" => app_mode) }

      # HTTPSのポートは script/secure_rails の内部で ENV['HTTPS_PORT'] を参照しています
      # desc "luanch HTTPS server"
      task(:launch_https_server       ){ system_at_root!("#{common_cmd} script/secure_rails server webrick", 'HTTPS_PORT' => config[:https_port], "FONTANA_APP_MODE" => app_mode ) }

      # desc "luanch HTTPS server daemon"
      task(:launch_https_server_daemon){ system_at_root!("#{common_cmd} script/secure_rails server webrick -d -P #{pid_dir}/#{app_mode}_https_server.pid", 'HTTPS_PORT' => config[:https_port], "FONTANA_APP_MODE" => app_mode) }

      # desc "luanch server daemons"
      task :launch_server_daemons => [:launch_http_server_daemon, :launch_https_server_daemon]

      # desc "shutdown server daemons"
      task :shutdown_server_daemons do
        Dir.glob(File.join(pid_dir, "#{app_mode}_*.pid")) do |pid_path|
          pid = `cat #{pid_path}`.strip
          system!("kill -INT #{pid}")
        end
      end

      desc "check #{app_mode} daemon alive"
      task :check_daemon_alive do
        pids = Dir.glob(File.join(pid_dir, "#{app_mode}_*.pid")).to_a
        raise "daemons seems to be still alive! #{pids.inspect}" unless pids.empty?
      end
    end

    namespace :servers do
      desc "start #{app_mode} HTTP+HTTPS server daemons" if app_mode == :test
      task :start => :"#{app_mode}:server:launch_server_daemons"

      desc "stop #{app_mode} HTTP+HTTPS server daemons"  if app_mode == :test
      task :stop => :"#{app_mode}:erver:shutdown_server_daemons"

      desc "restart #{app_mode} HTTP+HTTPS server daemons"  if app_mode == :test
      task_sequential(:restart, [:"#{app_mode}:servers:stop", :"#{app_mode}:servers:start"])
    end

  end
end


namespace :servers do
  desc "start development HTTP+HTTPS server daemons"
  task :start => :"development:servers:start"

  desc "stop development HTTP+HTTPS server daemons"
  task :stop => :"development:servers:stop"

  desc "restart development HTTP+HTTPS server daemons"
  task :restart => :"development:servers:restart"
end
