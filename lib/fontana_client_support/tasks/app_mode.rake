# -*- coding: utf-8 -*-
require 'fontana_client_support'

namespace :app_mode do

  desc "show app_mode"
  task :show do
    puts Fontana.app_mode.inspect
  end

  # 以下に:productionがありませんが、rakeタスクでproductionに設定することは想定できないので、敢えて作っていません。

  desc "set app_mode test"
  task :test do
    Fontana.app_mode = "test"
  end

  desc "set app_mode development"
  task :development do
    Fontana.app_mode = "development"
  end

end

task :app_model => :"app_mode:show"
