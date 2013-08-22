# -*- coding: utf-8 -*-
require 'fontana_client_support'

extend Fontana::RakeUtils

desc "Run RSpec with server_daemons"
task_sequential :spec_with_server_daemons, [
  :"vendor:fontana:prepare",
  :"test:server:spawn_servers",
  :"server:wait_to_launch",
  :spec
]
