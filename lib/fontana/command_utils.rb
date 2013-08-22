require 'fontana'
require 'fileutils'
require "shellwords"

module Fontana
  module CommandUtils

    module_function

    def system_at_vendor_fontana!(cmd, env = {}, &block)
      FileUtils::Verbose.chdir(FontanaClientSupport.vendor_fontana) do
        return system!(cmd, env, &block)
      end
    end

    def system!(cmd, env = {})
      unless env.empty?
        cmd = build_env_string(env) << " " << cmd
      end
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

    def build_env_string(env)
      env.each_with_object([]){|(key, value), d|
        d << "#{key}=#{value.to_s.shellescape}"
      }.join(" ")
    end

  end
end
