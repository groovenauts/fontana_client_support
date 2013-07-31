require 'spec_helper'

require 'httpclient'
require 'json'

describe FontanaClientSupport::ConfigServer do

  before do
    path = File.expand_path("../config_server_sample1", __FILE__)
    FontanaClientSupport.root_dir = path
    # FontanaClientSupport::ConfigServer.start_daemon(:Port => 3002, :DocumentRoot => path)
    FontanaClientSupport::ConfigServer.start_daemon(:Port => 3002)
    sleep(3)
  end

  after do
    FontanaClientSupport::ConfigServer.stop_daemon
  end

  it "get develop.json" do
    c = HTTPClient.new
    JSON.parse(c.get_content("http://localhost:3002/api_server/1/develop.json")).should == {
      "http_url_base" => "http://localhost:3000",
      "https_url_base" => "https://localhost:3001",
    }
  end

end
