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

    def current_branch_name
      @current_branch_name ||= `git log --decorate -1`.scan(/^commit\s[0-9a-f]+\s\((.+)\)/).
        flatten.first.split(/,/).map(&:strip).select{|s| s =~ /origin\//}.
        reject{|s| s == "origin/HEAD"}.first.sub(/\Aorigin\//, '')
    end

    def repo_url
      @repo_url ||= `git remote -v`.scan(/origin\s+(.+?)\s/).flatten.uniq.first
    end

    def deploy_strategy
      @deploy_strategy ||= :deploy
    end
    attr_writer :deploy_strategy

    def config
      yield(self) if block_given?
      self
    end
  end
end

require 'fontana'

Fontana.repo_url = ENV['FONTANA_REPO_URL']
Fontana.branch   = ENV['FONTANA_BRANCH'  ] || 'master'
Fontana.gemfile  = ENV['FONTANA_GEMFILE' ] || "Gemfile-LibgssTest"
