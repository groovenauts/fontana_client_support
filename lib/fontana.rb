
module Fontana
  autoload :CommandUtils, 'fontana/command_utils'
  autoload :ServerRake  , 'fontana/server_rake'

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

  end
end
