# -*- coding: utf-8 -*-
require 'fontana_client_support'
include Fontana::ServerRake

namespace :deploy do

  # このタスク群は scm:* と対になっています。
  namespace_with_fontana :sync, :"app:sync" do

    env = {
      "RUNTIME_SOURCE" => File.expand_path(".", FontanaClientSupport.root_dir)
    }

    desc "deploy:sync:setup + deploy:sync:update"
    fontana_task :reset, env: env

    desc "drop DB + initialize DB + clear runtime workspace. same as app:sync:setup"
    fontana_task :setup

    desc "update files to untime"
    fontana_task :update_files, env: env

    desc "update files to runtime + app_seed:build_from_runtime + migrate."
    fontana_task :update, env: env

    desc "db:drop, db:seed, app_seed:build_from_runtime + migrate."
    fontana_task :reset_db
  end

end
