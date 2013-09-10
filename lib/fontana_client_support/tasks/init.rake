require 'fontana_client_support'
include Fontana::CommandUtils

namespace :clear do
  desc "CAUTION! clear databases and vendor/fontana"
  task :all => [:"db:drop:all", :"vendor:fontana:clear"] do
    Dir.chdir(FontanaClientSupport.root_dir) do
      if `git diff`.strip.empty?
        puts "\e[32mOK"
      else
        puts "\e[31mThere is/are different(s). Please, commit and/or revert your changes.\n" << `git status` << "\e[0m"
      end
    end
  end
end
