# -*- coding: utf-8 -*-
require 'fontana_client_support'
include Fontana::ServerRake

# このタスク群は scm:* と対になっています。
namespace_with_fontana :sync, :"app:sync" do

  runtime_source = ->{
    ENV["RUNTIME_SOURCE"] = File.expand_path(".", FontanaClientSupport.root_dir)
  }


  desc "sync:setup sync:update"
  fontana_task :reset, before: runtime_source

  desc "drop DB, initialize, clear runtime workspace. same as app:sync:setup"
  fontana_task :setup

  desc "update app_seed:build_from_runtime and migrate. $RUNTIME_SOURCE is required."
  fontana_task :update, before: runtime_source
end
