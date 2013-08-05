require 'fontana_client_support'

module FontanaClientSupport
  class ConfigServer

    # see http://doc.ruby-lang.org/ja/1.9.3/class/WEBrick=3a=3aHTTPServer.html
    def initialize(config = {})
      @config = {
        :DocumentRoot => File.join(FontanaClientSupport.root_dir, "config_server"),
        :BindAddress => ENV['GSS_CONFIG_SERVER_ADDRESS'] || '127.0.0.1',
        :Port => (ENV['GSS_CONFIG_SERVER_PORT'] || 80).to_i
      }
      @config.update(config)
    end

    def launch
      require 'webrick'
      server = WEBrick::HTTPServer.new(@config)
      puts "config_server options: #{@config.inspect}"
      Signal.trap(:INT){ server.shutdown }
      server.start
    end

    class << self

      def start_daemon(options = {})
        pid_dir = File.join(FontanaClientSupport.root_dir, "tmp/pids")
        pid_file = File.join(pid_dir, "config_server.pid")
        if File.exist?(pid_file)
          raise "Can't start config server daemon because #{pid_file} already exists."
        end
        FileUtils.mkdir_p(pid_dir)
        pid = fork do
          $PROGRAM_NAME = __FILE__
          open(pid_file, "w") do |f|
            f.write(Process.pid)
          end
          $stdout.reopen("/dev/null")
          $stderr.reopen("/dev/null")
          begin
            self.new(options).launch
          ensure
            File.delete(pid_file)
          end
        end
        puts "#{Process.pid} launches child process by #{name}.start_daemon returns #{pid}"
        pid
      end

      def stop_daemon
        pid_dir = File.join(FontanaClientSupport.root_dir, "tmp/pids")
        Dir[File.join(pid_dir, "config_server.pid")].each do |filepath|
          pid = File.read(filepath)
          Process.kill("INT", pid.to_i)
        end
      end
    end

  end

end
