# -*- coding: utf-8 -*-
require 'fontana_client_support'

include Fontana::CommandUtils
extend Fontana::RakeUtils

namespace :server do
  task :wait_to_launch do
    sleep( (ENV["FONTANA_WAIT_TO_LAUNCH"] || 5).to_i ) # 実際にポートをLINSTENするまで待ちたい
  end
end

{
  development: {http_port: 3000, https_port: 3001 },
  test:        {http_port: 4000, https_port: 4001 },
}.each do |app_mode, config|
  namespace app_mode.to_sym do

    pid_dir = File.join(FontanaClientSupport.root_dir, "tmp/pids")

    namespace :server do
      common_cmd = "BUNDLE_GEMFILE=Gemfile-LibgssTest bundle exec"

      # desc "luanch HTTP server"
      task( :launch_http_server       ){ system_at_vendor_fontana!("#{common_cmd} rails server -p #{config[:http_port]}", "FONTANA_APP_MODE" => app_mode) }

      # desc "luanch HTTP server daemon"
      task(:launch_http_server_daemon ){ system_at_vendor_fontana!("#{common_cmd} rails server -p #{config[:http_port]} -d -P #{pid_dir}/#{app_mode}_http_server.pid", "FONTANA_APP_MODE" => app_mode) }

      # HTTPSのポートは script/secure_rails の内部で ENV['HTTPS_PORT'] を参照しています
      # desc "luanch HTTPS server"
      task(:launch_https_server       ){ system_at_vendor_fontana!("#{common_cmd} script/secure_rails server webrick", 'HTTPS_PORT' => config[:https_port], "FONTANA_APP_MODE" => app_mode ) }

      # desc "luanch HTTPS server daemon"
      task(:launch_https_server_daemon){ system_at_vendor_fontana!("#{common_cmd} script/secure_rails server webrick -d -P #{pid_dir}/#{app_mode}_https_server.pid", 'HTTPS_PORT' => config[:https_port], "FONTANA_APP_MODE" => app_mode) }

      # desc "luanch server daemons"
      task :launch_server_daemons => [:launch_http_server_daemon, :launch_https_server_daemon]
    end

    namespace :servers do
      desc "start #{app_mode} HTTP+HTTPS server daemons" if app_mode == :test
      task :start => :"#{app_mode}:server:launch_server_daemons"

      desc "stop #{app_mode} HTTP+HTTPS server daemons"  if app_mode == :test
      task :stop => :"#{app_mode}:servers:shutdown_server_daemons"

      desc "stop #{app_mode} HTTP+HTTPS server daemons when process exit" if app_mode == :test
      task :stop_on_exit do
        at_exit{ Rake::Task["test:servers:stop"].execute }
      end

      desc "restart #{app_mode} HTTP+HTTPS server daemons"  if app_mode == :test
      task_sequential(:restart, [:"#{app_mode}:servers:stop", :"#{app_mode}:servers:start"])

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
        unless pids.empty?
          msg = "\e[31mdaemons seems to be still alive! #{pids.inspect}\n"
          cmd = "ps " + pids.map{|pid| "-p `cat #{pid}`" }.join(" ")
          msg << `#{cmd}`
          msg << "\e[0m"
          raise msg
        end
      end
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
