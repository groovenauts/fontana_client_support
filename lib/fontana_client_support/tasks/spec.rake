# -*- coding: utf-8 -*-
require 'fontana_client_support'

extend Fontana::RakeUtils

desc "Run RSpec with server_daemons"
task_sequential :spec_with_server_daemons, [
  :"test:servers:check_daemon_alive",
  :"vendor:fontana:prepare",
  :"test:servers:start",
  :"test:servers:stop_on_exit",
  :"server:wait_to_launch",
  :spec
]
