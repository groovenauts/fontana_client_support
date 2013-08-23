# -*- coding: utf-8 -*-
require 'fontana_client_support'

require 'timeout'

include Fontana::CommandUtils
extend Fontana::RakeUtils

def build_env_str(env)
  env.each_with_object([]){|(k,v), d|
    d << "#{k.to_s}=#{v.to_s}"
  }.join(" ")
end

{
  development: {http_port: 3000, https_port: 3001 },
  test:        {http_port: 4000, https_port: 4001 },
}.each do |app_mode, config|
  namespace app_mode.to_sym do

    pid_dir = File.join(FontanaClientSupport.vendor_fontana, "tmp/pids")

    namespace :server do
      http_env = {FONTANA_APP_MODE: app_mode, BUNDLE_GEMFILE: "Gemfile-LibgssTest" }
      https_env = http_env.merge(HTTPS_PORT: config[:https_port])

      http_env_str = build_env_str(http_env)
      https_env_str = build_env_str(https_env)

      desc "update VersionSet entries' versions and copy collections"
      task(:update_version_set_entries) do
        if ENV["GSS_VERSION_SET_FIXTURE_FILEPATH"]
          system_at_vendor_fontana!(http_env_str + " rake version_set:update_entry_versions")
        end
      end

      http_base_cmd = "bundle exec rails server -p #{config[:http_port]}"
      http_fg_cmd = "#{http_env_str} #{http_base_cmd}"
      http_bg_cmd = "#{http_env_str} #{http_base_cmd} -d -P #{pid_dir}/#{app_mode}_http_server.pid"

      # HTTPSのポートは script/secure_rails の内部で ENV['HTTPS_PORT'] を参照しています
      https_base_cmd = "bundle exec script/secure_rails server webrick"
      https_fg_cmd = "#{https_env_str} #{https_base_cmd}"
      https_bg_cmd = "#{https_env_str} #{https_base_cmd} -d -P #{pid_dir}/#{app_mode}_https_server.pid"

      {
        launch_http_server:         http_fg_cmd,
        launch_http_server_daemon:  http_bg_cmd,
        launch_https_server:        https_fg_cmd,
        launch_https_server_daemon: https_bg_cmd,
      }.each do |name, cmd|
        task(name){ system_at_vendor_fontana!(cmd) }
      end

      task_sequential :launch_server_daemons, [
        :"#{app_mode}:server:update_version_set_entries",
        :"#{app_mode}:server:launch_http_server_daemon",
        :"#{app_mode}:server:launch_https_server_daemon"
      ]

      spawn_env = {FONTANA_APP_MODE: app_mode, BUNDLE_GEMFILE: "Gemfile-LibgssTest" }
      task(:spawn_http_server){ spawn_at_vendor_fontana_with_sweeper(http_env, http_base_cmd, out: "/dev/null") }
      task(:spawn_https_server){ spawn_at_vendor_fontana_with_sweeper(https_env, https_base_cmd, out: "/dev/null") }

      task_sequential :spawn_servers, [
        :"#{app_mode}:server:update_version_set_entries",
        :"#{app_mode}:server:spawn_http_server",
        :"#{app_mode}:server:spawn_https_server"
      ]

      {
        http: config[:http_port],
        https: config[:https_port],
      }.each do |name, port|

        task(:"error_on_#{name}_listened") do
          lsof = `lsof -i:#{port}`
          if lsof =~ /LISTEN/
            raise "\e[31mAnother server is already running on #{port}. Stop it in order to run new server.\n#{lsof}\e[0m"
          end
        end

        task(:"wait_to_listen_#{name}") do
          timeout((ENV["WAIT_TO_LISTEN"] || 120).to_i) do
            while true
              break if `lsof -i:#{port}` =~ /LISTEN/
              sleep(0.2)
            end
          end
        end
      end

      desc "error on ports listened by some server"
      task :error_on_ports_listened => [
        :error_on_http_listened,
        :error_on_https_listened,
      ]

      desc "wait to listen ports"
      task :wait_to_listen_ports => [
        :wait_to_listen_http,
        :wait_to_listen_https,
      ]

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
          msg << "\n You can stop these daemons by using `rake test:servers:stop`"
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
