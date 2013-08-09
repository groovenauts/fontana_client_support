require 'fontana_client_support'
require 'tmpdir'
require 'fileutils'

module FontanaClientSupport
  class ConfigServer

    # see http://doc.ruby-lang.org/ja/1.9.3/class/WEBrick=3a=3aHTTPServer.html
    def initialize(config = {})
      @config = config
    end

    def launch
      require 'webrick'
      root_dir = FontanaClientSupport.root_dir
      document_root_source = @config[:document_root] || root_dir ? File.join(root_dir, "config_server") : "."
      Dir.mktmpdir("fontana_config_server") do |dir|
        if @config[:document_root] or root_dir.nil?
          document_root = document_root_source
        else
          git_dir       = File.join(dir, "workspace")
          document_root = File.join(dir, "document_root")
          FileUtils.cp_r(document_root_source, document_root)
        end

        server_config = {
          :DocumentRoot => document_root,
          :BindAddress => @config[:address] || ENV['GSS_CONFIG_SERVER_ADDRESS'],
          :Port => (@config[:port] || ENV['GSS_CONFIG_SERVER_PORT'] || 80).to_i
        }
        server = WEBrick::HTTPServer.new(server_config)
        if FontanaClientSupport.root_dir
          server.mount_proc('/switch_config_server') do |req, res|
            unless Dir.exist?(git_dir)
              FileUtils.cp_r(root_dir, git_dir)
            end
            tag = req.path.sub(%r{\A/switch_config_server/}, '')
            Dir.chdir(git_dir) do
              system("git reset --hard #{tag}")
              FileUtils.rm_rf(document_root)
              FileUtils.cp_r(File.join(git_dir, "config_server"), document_root)
            end
            res.body = Dir["#{document_root}/**/*"].to_a.join("\n  ")
          end
        end
        puts "config_server options: #{@config.inspect}"
        Signal.trap(:INT){ server.shutdown }
        server.start
      end
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
        # puts "#{Process.pid} launches child process by #{name}.start_daemon returns #{pid}"
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
