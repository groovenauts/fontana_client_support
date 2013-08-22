# -*- coding: utf-8 -*-
require 'fontana_client_support'
include Fontana::ServerRake

namespace :deploy do

  # このタスク群は scm:* と対になっています。
  namespace_with_fontana :sync, :"app:sync" do

    runtime_source = ->{
      ENV["RUNTIME_SOURCE"] = File.expand_path(".", FontanaClientSupport.root_dir)
    }


    desc "deploy:sync:setup + deploy:sync:update"
    fontana_task :reset, before: runtime_source

    desc "drop DB + initialize DB + clear runtime workspace. same as app:sync:setup"
    fontana_task :setup

    desc "update runtime + app_seed:build_from_runtime + migrate."
    fontana_task :update, before: runtime_source

    desc "db:drop, db:seed, app_seed:build_from_runtime + migrate."
    fontana_task :update_db
  end

end
