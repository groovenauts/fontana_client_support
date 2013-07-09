# -*- coding: utf-8 -*-
require 'fontana_client_support'
include Fontana::ServerRake
include Fontana::RakeUtils

require 'fileutils'

namespace :vendor do
  namespace :fontana do

    fileutils = FileUtils::Verbose

    task :clear do
      d = FontanaClientSupport.vendor_fontana
      fileutils.rm_rf(d) if Dir.exist?(d)
    end

    # 動的に決まるタスクを静的に扱えるようにタスクを定義します
    task :deploy_reset do
      Rake::Task["deploy:#{FontanaClientSupport.deploy_strategy}:reset"].delegate
    end
    task :deploy_update do
      Rake::Task["deploy:#{FontanaClientSupport.deploy_strategy}:update"].delegate
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
        system!("git checkout #{Fontana.branch}")
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
      name = Dir.exist?(FontanaClientSupport.vendor_fontana) ? "update" : "reset"
      Rake::Task["vendor:fontana:#{name}"].delegate
    end
  end

end
