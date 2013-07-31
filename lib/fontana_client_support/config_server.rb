require 'fontana_client_support'

module FontanaClientSupport
  class ConfigServer

    # see http://doc.ruby-lang.org/ja/1.9.3/class/WEBrick=3a=3aHTTPServer.html
    def initialize(config = {})
      @config = {
        :DocumentRoot => File.join(FontanaClientSupport.root_dir, "config_server"),
        :BindAddress => '127.0.0.1',
        :Port => 80
      }
      @config.update(config)
    end

    def launch
      require 'webrick'
      server = WEBrick::HTTPServer.new(@config)
      Signal.trap(:INT){ server.shutdown }
      server.start
    end

    class << self

      def start_daemon(options = {})
        # Process.daemon(true, true)
        Process.daemon(true)
        pid_dir = File.join(FontanaClientSupport.root_dir, "tmp/pids")
        FileUtils.mkdir_p(pid_dir)
        open(File.join(pid_dir, "config_server.pid"), "w") do |f|
          f.write(Process.pid)
        end
        self.new(options).launch
      end

      def stop_daemon
        pid_dir = File.join(FontanaClientSupport.root_dir, "tmp/pids")
        Dir[File.join(pid_dir, "config_server.pid")].each do |filepath|
          pid = File.read(filepath)
          Process.kill("-INT", pid.to_i)
        end
      end

    end

  end

end
