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
          # http://qiita.com/sugyan/items/83e060e895fa8ef2038c
          s = `git describe --tags`
          s.scan(/\A(v\d+\.\d+\.\d+)/).flatten.first
        end
      end
    end

    def vendor_fontana_branch
      return nil unless Dir.exist?(FontanaClientSupport.vendor_fontana)
      Dir.chdir(FontanaClientSupport.vendor_fontana) do
        return FontanaClientSupport.git_current_branch_name
      end
    end

    def raise_if_fontana_branch_empty
      if Fontana.branch.nil? || Fontana.branch.empty?
        # FONTANA_BRANCHがnilならmasterが設定されているはずです
        raise "\e[31mInvalid FONTANA_BRANCH: #{ENV['FONTANA_BRANCH'].inspect}. Please set valid value or unset FONTANA_BRANCH.\e[0m"
      end
    end

    task :version do
      puts vendor_fontana_version
    end

    task :clear => :"servers:stop:all" do
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
      raise_if_fontana_branch_empty
      raise "$FONTANA_REPO_URL is required" unless Fontana.repo_url
      fileutils.mkdir_p(FontanaClientSupport.vendor_dir)
      fileutils.chdir(FontanaClientSupport.root_dir) do
        system!("git clone #{Fontana.repo_url} vendor/fontana -b #{Fontana.branch}")
      end
      fileutils.chdir(FontanaClientSupport.vendor_fontana) do
        unless Fontana.version.nil? || Fontana.version.empty?
          system!("git checkout master && git reset --hard #{Fontana.version}")
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
      raise_if_fontana_branch_empty

      vfb = vendor_fontana_branch
      vfv = vendor_fontana_version

      puts "vendor/fontana branch: #{vfb.inspect} version: #{vfv.inspect}"
      puts "      required branch: #{Fontana.branch.inspect} version: #{Fontana.version.inspect}"

      if !Dir.exist?(FontanaClientSupport.vendor_fontana)
        # vendor/fontana が存在しない場合
        puts "\e[34mvendor/fontana does not exist.\e[0m"
        Rake::Task["vendor:fontana:reset"].delegate

      elsif vfb != Fontana.branch
        # vendor/fontanaのブランチが FONTANA_BRANCH と異なる場合
        # puts "\e[33m but FONTANA_BRANCH is #{Fontana.branch}\e[0m"
        Rake::Task["vendor:fontana:reset"].delegate

      elsif Fontana.version.nil? || Fontana.version.empty?
        # FONTANA_BRANCHとvendor/fontanaのブランチが同じで、FONTANA_VERSIONが指定されていない場合
        puts "\e[34mvendor/fontana's branch is #{vfb} as same as FONTANA_BRANCH. Now pulling origin #{vfb.inspect} \e[0m"
        fileutils.chdir(FontanaClientSupport.vendor_fontana) do
          system!("git pull origin #{Fontana.branch}; git status")
        end

      elsif vfv.nil?
        # FONTANA_BRANCHとvendor/fontanaのブランチが同じで、vendor/fontanaのバージョンが取得できない場合
        puts "\e[33mversion not found in vendor/fontana\e[0m"
        Rake::Task["vendor:fontana:reset"].delegate

      elsif vfv == Fontana.version
        # FONTANA_BRANCHとvendor/fontanaのブランチが同じで、FONTANA_VERSIONが指定されていて、vendor/fontanaのバージョンと同じものの場合
        puts "\e[32m#{Fontana.version} is already used.\e[0m"

      else
        # FONTANA_BRANCHとvendor/fontanaのブランチが同じで、FONTANA_VERSIONが指定されていて、vendor/fontanaのバージョンと異なる場合
        puts "\e[33m#{vfv} is used but FONTANA_VERSION is #{Fontana.version}\e[0m"
        # name = Dir.exist?(FontanaClientSupport.vendor_fontana) ? "update" : "reset"
        # Rake::Task["vendor:fontana:#{name}"].delegate
        Rake::Task["vendor:fontana:reset"].delegate

      end
    end


  end

end
