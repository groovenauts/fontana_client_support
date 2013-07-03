# -*- coding: utf-8 -*-
require 'fontana_client_support'
include Fontana::ServerRake

# このタスク群は sync:* と対になっています。
namespace_with_fontana :scm, :"app:scm" do

  set_url_and_branch = ->{
    ENV['URL'] ||= FontanaClientSupport.repo_url
    ENV['BRANCH'] ||= FontanaClientSupport.current_branch_name
  }

  desc "scm:setup, clone, checkout branch, scm:update. $URL required."
  fontana_task :reset, before: set_url_and_branch

  desc "drop DB, initialize, clear runtime workspace."
  fontana_task :setup

  desc "fetch, checkout, build app_seed and migrate."
  fontana_task :update
end
