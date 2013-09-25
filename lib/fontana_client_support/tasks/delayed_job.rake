require 'fontana_client_support'

include Fontana::CommandUtils
extend Fontana::RakeUtils

def build_env_str(env)
  env.each_with_object([]){|(k,v), d|
    d << "#{k.to_s}=#{v.to_s}"
  }.join(" ")
end

[:development, :test].each do |app_mode|
  namespace app_mode do
    namespace :delayed_job do

      cmd_env = {FONTANA_APP_MODE: app_mode, BUNDLE_GEMFILE: "Gemfile-LibgssTest" }
      cmd_env_str = build_env_str(cmd_env)

      commands = {
        start:   "start an instance of the application",
        stop:    "stop all instances of the application",
        restart: "stop all instances and restart them afterwards",
        reload:  "send a SIGHUP to all instances of the application",
        run:     "start the application and stay on top",
        zap:     "set the application to a stopped state",
        status:  "show status (PID) of application instances",
      }

      commands.each do |cmd, description|
        desc description
        task cmd do
          s = cmd_env_str + " bundle exec script/delayed_job #{cmd}"
          options_str = ENV['OPTIONS']
          unless options_str.nil? || options_str.empty?
            s << " " << options_str
          end
          app_options_str = ENV['APP_OPTIONS']
          unless app_options_str.nil? || app_options_str.empty?
            s << " -- " << app_options_str
          end
          system_at_vendor_fontana!(s)
        end
      end

      desc "show help"
      task :help do
        system_at_vendor_fontana!("delayed_job --help")
      end

    end
  end
end
