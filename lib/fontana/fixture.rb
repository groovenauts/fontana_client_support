require "fontana"

require 'httpclient'

module Fontana

  module Fixture
    def load_fixture(fixture_name, options = {})
      options = options.update({host: "localhost", port: 3000})
      c = HTTPClient.new
      res = c.post("http://#{options[:host]}:#{options[:port]}/libgss_test/fixture_loadings/#{fixture_name}.json", "_method" => "put")
      raise "#{res.code} #{res.http_body.content}" unless res.code.to_s =~ /\A2\d\d\Z/
    end
  end

end
