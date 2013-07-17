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
      unless @current_branch_name
        work = `git log --decorate -1 --branches`.scan(/^commit\s[0-9a-f]+\s\((.+)\)/).
          flatten.first.split(/,/).map(&:strip).reject{|s| s =~ /HEAD\Z/}
        r = work.select{|s| s =~ /origin\//}.first
        r ||= work.first
        @current_branch_name = r.sub(/\Aorigin\//, '')
      end
      @current_branch_name
    rescue => e
      puts "[#{e.class}] #{e.message}"
      puts "Dir.pwd: #{Dir.pwd}"
      puts "git log --decorate -1\n" << `git log --decorate -1`
      raise e
    end

    def repo_url
      @repo_url ||= `git remote -v`.scan(/origin\s+(.+?)\s/).flatten.uniq.first
    end

    def deploy_strategy
      @deploy_strategy ||= :deploy
    end

    DEPLOY_STRATEGY_NAMES = [:scm, :sync].freeze

    def deploy_strategy=(v)
      unless DEPLOY_STRATEGY_NAMES.include?(v)
        raise ArgumentError, "invalid deploy_strategy: #{v.inspect} must be one of #{DEPLOY_STRATEGY_NAMES.inspect}"
      end
      @deploy_strategy = v
    end

    def configure
      yield(self) if block_given?
      self
    end
  end
end

require 'fontana'

Fontana.repo_url = ENV['FONTANA_REPO_URL']
Fontana.branch   = ENV['FONTANA_BRANCH'  ] || 'master'
Fontana.gemfile  = ENV['FONTANA_GEMFILE' ] || "Gemfile-LibgssTest"
