# -*- coding: utf-8 -*-

module Fontana
  autoload :CommandUtils, 'fontana/command_utils'
  autoload :ServerRake  , 'fontana/server_rake'
  autoload :RakeUtils   , 'fontana/rake_utils'

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

  end
end
