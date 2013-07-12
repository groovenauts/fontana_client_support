require 'fontana'

module Fontana
  module CommandUtils

    module_function

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
