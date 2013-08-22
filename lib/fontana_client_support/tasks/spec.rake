# -*- coding: utf-8 -*-
require 'fontana_client_support'

extend Fontana::RakeUtils

desc "Run RSpec with server_daemons"
task_sequential :spec_with_server_daemons, [
  :"test:server:error_on_ports_listened",
  :"vendor:fontana:prepare",
  :"test:server:spawn_servers",
  :"test:server:wait_to_listen_ports",
  :spec
]
