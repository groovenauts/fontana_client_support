# -*- coding: utf-8 -*-
require 'fontana_client_support'
include Fontana::ServerRake

namespace_with_fontana :aggr, :aggr do

  desc "run aggregations"
  fontana_task :run

  desc "show explanation of steps"
  fontana_task :explain

  desc "show all generator_script"
  fontana_task :generator_scripts

  namespace_with_fontana :test, :test do
    desc "generate script and data for test of hadoop cluster"
    fontana_task :gen
  end

end
