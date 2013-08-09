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
      $stdout.puts "config_server options: #{@config.inspect}"
      $stdout.puts("root_dir             : #{root_dir.inspect}")
      $stdout.puts("document_root_source : #{document_root_source.inspect}")
      Dir.mktmpdir("fontana_config_server") do |dir|
        if @config[:document_root] or root_dir.nil?
          document_root = document_root_source
        else
          git_dir = File.join(dir, "workspace")
          document_root = File.join(dir, "document_root")
          FileUtils.cp_r(document_root_source, document_root)
        end

        $stdout.puts("document_root        : #{document_root.inspect}")
        $stdout.puts("git_dir              : #{git_dir.inspect}")

        server_config = {
          :DocumentRoot => document_root,
          :BindAddress => @config[:address] || ENV['GSS_CONFIG_SERVER_ADDRESS'],
          :Port => (@config[:port] || ENV['GSS_CONFIG_SERVER_PORT'] || 80).to_i
        }
        server = WEBrick::HTTPServer.new(server_config)
        if FontanaClientSupport.root_dir
          server.mount_proc('/switch_config_server') do |req, res|
            buf = []
            unless Dir.exist?(git_dir)
              if git_repo_url = @config[:git_repo_url] || ENV['GSS_CONFIG_SERVER_REPO_URL']
                Dir.chdir(dir) do
                  cmd = "git clone #{git_repo_url} #{File.basename(git_dir)}"
                  if system(cmd)
                    buf << "SUCCESS: #{cmd}"
                  else
                    buf << "ERROR: #{cmd}"
                  end
                end
              else
                FileUtils.cp_r(root_dir, git_dir)
                buf << "SUCCESS: cp -r #{root_dir} #{git_dir}"
              end
            end
            tag = req.path.sub(%r{\A/switch_config_server/}, '')
            if tag.nil? || tag.empty?
              bug << "no tag or SHA1 given"
            else
              Dir.chdir(git_dir) do
                if system("git reset --hard #{tag}")
                  FileUtils.rm_rf(document_root)
                  FileUtils.cp_r(File.join(git_dir, "config_server"), document_root)
                  buf << "SUCCESS"
                else
                  buf << "ERROR if you use in submodule, set $GSS_CONFIG_SERVER_REPO_URL.\nlike this:\n$ rake config_server:launch GSS_CONFIG_SERVER_PORT=3002 GSS_CONFIG_SERVER_REPO_URL=git@github.com:groovenauts/fontana_sample.git"
                end
              end
            end
            res.body = (buf + ["", "files: "] + Dir["#{document_root}/**/*"].to_a).join("\n  ")
          end
        end
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
