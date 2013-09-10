# -*- coding: utf-8 -*-
require 'fontana_client_support'
include Fontana::ServerRake
include Fontana::RakeUtils

require 'fileutils'

namespace :vendor do
  namespace :fontana do

    fileutils = FileUtils::Verbose

    def vendor_fontana_version
      d = FontanaClientSupport.vendor_fontana
      if Dir.exist?(d)
        Dir.chdir(d) do
          # log = `git log -1 --decorate --branches --tags` # これだと現在のコミットが先頭にならない
          log = `git log -1 --decorate --oneline`
          if t = log.split(/\s*,\s*/).detect{|s| s =~ /\Atag:\s*v?\d+\.\d+\.\d+/}
            t.split(/\s*:\s*/, 2).last
          else
            nil
          end
        end
      end
    end

    task :version do
      puts vendor_fontana_version
    end

    task :clear do
      d = FontanaClientSupport.vendor_fontana
      fileutils.rm_rf(d) if Dir.exist?(d)
    end

    case FontanaClientSupport.deploy_strategy
    when :scm then
      task :deploy_reset  => :"deploy:scm:reset"
      task :deploy_update => :"deploy:scm:update"
    when :sync then
      task :deploy_reset  => :"deploy:sync:reset"
      task :deploy_update => :"deploy:sync:update"
    end

    task_sequential :setup, [
      :"vendor:fontana:clone",
      :"vendor:fontana:configs",
      :"vendor:fontana:bundle_install",
      :"vendor:fontana:deploy_reset",
    ]

    task :clone do
      raise "$FONTANA_REPO_URL is required" unless Fontana.repo_url
      fileutils.mkdir_p(FontanaClientSupport.vendor_dir)
      fileutils.chdir(FontanaClientSupport.root_dir) do
        system!("git clone #{Fontana.repo_url} vendor/fontana")
      end
      fileutils.chdir(FontanaClientSupport.vendor_fontana) do
        if Fontana.version
          system!("git checkout master && git reset --hard #{Fontana.version}")
        else
          system!("git checkout #{Fontana.branch}")
        end
      end
    end

    task :configs do
      fileutils.chdir(FontanaClientSupport.vendor_fontana) do
        [
          File.join(FontanaClientSupport.root_dir, "config/fontana_mongoid.yml"),
          "config/mongoid.yml.example"
        ].each do |path|
          if File.readable?(path)
            fileutils.cp(path, "config/mongoid.yml")
            break
          end
        end
        fileutils.cp("config/project.yml.erb.example", "config/project.yml.erb")
      end
    end

    task :bundle_install do
      fileutils.chdir(FontanaClientSupport.vendor_fontana) do
        system!("BUNDLE_GEMFILE=#{Fontana.gemfile} bundle install")
      end
    end

    task_sequential :update, [
      :"vendor:fontana:fetch_and_checkout",
      :"vendor:fontana:configs",
      :"vendor:fontana:bundle_install",
      :"vendor:fontana:db_drop",
      :"vendor:fontana:deploy_update",
    ]

    task :fetch_and_checkout do
      fileutils.chdir(FontanaClientSupport.vendor_fontana) do
        system!("git fetch origin")
        system!("git checkout origin/#{Fontana.branch}")
      end
    end

    task :db_drop do
      fileutils.chdir(FontanaClientSupport.vendor_fontana) do
        system!("BUNDLE_GEMFILE=#{Fontana.gemfile} bundle exec rake db:drop")
      end
    end

    desc "reset vendor/fontana"
    task_sequential :reset, [:"vendor:fontana:clear", :"vendor:fontana:setup"]

    task :prepare do
      if vfv = vendor_fontana_version
        if vfv == Fontana.version
          puts "\e[32m#{Fontana.version} is already used.\e[0m"
        else
          puts "\e[33m#{vfv} is used but FONTANA_VERSION is #{Fontana.version}\e[0m"
          # name = Dir.exist?(FontanaClientSupport.vendor_fontana) ? "update" : "reset"
          # Rake::Task["vendor:fontana:#{name}"].delegate
          Rake::Task["vendor:fontana:reset"].delegate
        end
      else
        puts "\e[33mversion not found in vendor/fontana\e[0m"
        Rake::Task["vendor:fontana:reset"].delegate
      end
    end


  end

end
