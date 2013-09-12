require 'fontana_client_support'
include Fontana::CommandUtils

namespace :clear do
  desc "CAUTION! clear databases and vendor/fontana"
  task :all => [:"db:drop:all", :"vendor:fontana:clear"] do
    Dir.chdir(FontanaClientSupport.root_dir) do
      if `git diff`.strip.empty?
        puts "\e[32mOK\e[0m"
      else
        puts "\e[33mWARNING! There is/are different(s) from repository."  <<
          "If you want to make the same environment as repository, commit and/or discard your changes.\e[0m\n" <<
          `git status`
      end
    end
  end
end
