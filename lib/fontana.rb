# -*- coding: utf-8 -*-

module Fontana
  autoload :CommandUtils, 'fontana/command_utils'
  autoload :ServerRake  , 'fontana/server_rake'
  autoload :RakeUtils   , 'fontana/rake_utils'
  autoload :Fixture     , 'fontana/fixture'

  extend Fontana::Fixture

  class << self
    # attr_accessor :home
    attr_accessor :gemfile

    attr_accessor :repo_url

    def home
      @home ||= ENV['FONTANA_HOME'] || (Dir.exist?(FontanaClientSupport.vendor_fontana) or Fontana.repo_url) ? FontanaClientSupport.vendor_fontana : nil
    end

    def home=(value)
      @home = value
    end

    # これは fontanaの Fontana.env と同じ動きをすることが期待されています。
    # https://github.com/tengine/fontana/blob/master/config/application.rb#L24
    def env
      @env ||= (ENV["FONTANA_ENV"] || "DEVELOPMENT").to_sym
    end

    # これは fontanaの Fontana.app_mode と同じ動きをすることが期待されています。
    # https://github.com/tengine/fontana/blob/master/config/application.rb#L47
    def app_mode
      (ENV["FONTANA_APP_MODE"] || "test").to_sym # production development test
    end

    def app_mode=(value)
      ENV["FONTANA_APP_MODE"] = value
    end

    def branch
      unless @branch
        @branch = ENV['FONTANA_BRANCH' ]
        load_fontana_version_file unless @branch
      end
      @branch
    end

    def version
      unless @version
        @version = ENV['FONTANA_VERSION' ]
        load_fontana_version_file unless @version
      end
      @version
    end

    def load_fontana_version_file
      path = File.expand_path("FONTANA_VERSION", FontanaClientSupport.root_dir)
      line = File.read(path).strip
      @version, @branch = line.split(/\@/, 2).map{|s| s.empty? ? nil : s }
      @branch ||= "master"
    end
    private :load_fontana_version_file

    def development_http_server_port
      (ENV["FONTANA_DEVELOPMENT_HTTP_SERVER_PORT" ] || 3000).to_i
    end

    def development_https_server_port
      (ENV["FONTANA_DEVELOPMENT_HTTPS_SERVER_PORT"] || 3001).to_i
    end

    def test_http_server_port
      (ENV["FONTANA_TEST_HTTP_SERVER_PORT" ] || 4000).to_i
    end

    def test_https_server_port
      (ENV["FONTANA_TEST_HTTPS_SERVER_PORT"] || 4001).to_i
    end

    def test_server_url(hostname = "localhost")
      "http://#{hostname}:#{test_http_server_port}"
    end

  end
end
