require 'fontana_client_support'
include Fontana::ServerRake

namespace_with_fontana :deploy, :"app:deploy" do

  set_url_and_branch = ->{
    ENV['URL'] ||= FontanaClientSupport.repo_url
    ENV['BRANCH'] ||= FontanaClientSupport.current_branch_name
  }

  desc "deploy:setup deploy:update"
  fontana_task :reset, before: set_url_and_branch

  desc "drop DB, initialize, clear workspaces, clone, checkout branch. $URL required."
  fontana_task :setup, before: set_url_and_branch

  desc "fetch, checkout, build app_seed and migrate."
  fontana_task :update, before: set_url_and_branch
end
