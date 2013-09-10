require 'fontana_client_support'
include Fontana::CommandUtils

namespace :clear do
  desc "CAUTION! clear databases and vendor/fontana"
  task :all => [:"db:drop:all", :"vendor:fontana:clear", :_show_git_diff]

  task :_show_git_diff do
    Dir.chdir(FontanaClientSupport.root_dir) do
      unless `git diff`.strip.empty?
        puts "There is/are different(s). commit and/or revert your changes.\n" << `git status`
      end
    end
  end
end
