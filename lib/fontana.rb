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
    attr_accessor :branch

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
      (ENV["FONTANA_APP_MODE"] || "development").to_sym # production development test
    end

    def app_mode=(value)
      ENV["FONTANA_APP_MODE"] = value
    end

    def version
      unless @version
        @version = ENV['FONTANA_VERSION' ]
        unless @version
          path = File.expand_path("FONTANA_VERSION", FontanaClientSupport.root_dir)
          @version = File.read(path).strip if File.readable?(path)
        end
      end
      @version
    end

  end
end
