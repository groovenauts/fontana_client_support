require 'fontana'
require 'fileutils'
require "shellwords"

module Fontana
  module CommandUtils

    module_function

    def system_at_vendor_fontana!(cmd, &block)
      FileUtils::Verbose.chdir(FontanaClientSupport.vendor_fontana) do
        return system!(cmd, &block)
      end
    end

    def spawn_at_vendor_fontana(env, cmd, options = {})
      options = { chdir: FontanaClientSupport.vendor_fontana }.update(options)
      env = env.each_with_object({}){|(k,v), d| d[k.to_s] = v.to_s }
      puts "now spawning:\n  env: #{env.inspect}\n  cmd: #{cmd.inspect}\n  options: #{options.inspect}"
      pid = spawn(env, cmd, options)
      puts "spawning suceeded pid: #{pid.inspect}"
      Process.detach(pid)
      return pid
    end

    def spawn_at_vendor_fontana_with_sweeper(env, cmd)
      pid = spawn_at_vendor_fontana(env, cmd)
      at_exit{
        puts "Now killing #{pid}"
        Process.kill("INT", pid)
      }
      pid
    end

    def system!(cmd)
      puts "now executing: #{cmd}"

      buf = []
      IO.popen("#{cmd} 2>&1") do |io|
        while line = io.gets
          puts line
          buf << line
        end
      end

      if $?.exitstatus != 0
        $stderr.puts("\e[31mFAILURE: %s\n%s\e[0m" % [cmd, buf.join.strip])
        exit(1)
      end
    end

  end
end
