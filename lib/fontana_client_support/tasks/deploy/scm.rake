# -*- coding: utf-8 -*-
require 'fontana_client_support'
include Fontana::ServerRake

namespace :deploy do

  # このタスク群は sync:* と対になっています。
  namespace_with_fontana :scm, :"app:scm" do

    set_url_and_branch = ->{
    }

    desc "deploy:scm:setup + clone (+ checkout branch) + deploy:scm:update."
    fontana_task :reset, env: {
      'URL' => FontanaClientSupport.repo_url,
      'BRANCH' => FontanaClientSupport.current_branch_name
    }

    desc "drop DB, initialize, clear runtime workspace."
    fontana_task :setup

    desc "fetch, checkout, build app_seed and migrate."
    fontana_task :update

    desc "db:drop, db:seed, build app_seed and migrate."
    fontana_task :reset_db
  end

end
