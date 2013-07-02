require "fontana_client_support/version"

module FontanaClientSupport

  class << self
    attr_accessor :root_dir

    def vendor_dir
      @vendor_dir ||= File.join(root_dir, "vendor")
    end

    def vendor_fontana
      @vendor_fontana ||= File.join(vendor_dir, "fontana")
    end
  end
end

require 'fontana'

Fontana.repo_url = ENV['FONTANA_REPO_URL']
Fontana.branch   = ENV['FONTANA_BRANCH'  ] || 'master'
Fontana.gemfile  = ENV['FONTANA_GEMFILE' ] || "Gemfile-LibgssTest"
Fontana.home     = ENV['FONTANA_HOME'    ] || (Dir.exist?(FontanaClientSupport.vendor_fontana) or Fontana.repo_url) ? FontanaClientSupport.vendor_fontana : nil
