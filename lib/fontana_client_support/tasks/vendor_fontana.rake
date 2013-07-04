require 'fontana_client_support'
include Fontana::ServerRake
include Fontana::RakeUtils

namespace :vendor do
  namespace :fontana do

    task :clear do
      d = FontanaClientSupport.vendor_fontana
      FileUtils.rm_rf(d) if Dir.exist?(d)
    end

    task :setup do
      raise "$FONTANA_REPO_URL is required" unless Fontana.repo_url
      FileUtils.mkdir_p(FontanaClientSupport.vendor_dir)
      Dir.chdir(FontanaClientSupport.root_dir) do
        system!("git clone #{Fontana.repo_url} vendor/fontana")
      end
      Dir.chdir(FontanaClientSupport.vendor_fontana) do
        system!("git checkout #{Fontana.branch}")
        FileUtils.cp(File.join(FontanaClientSupport.root_dir, "spec/server_config/mongoid.yml"), "config/mongoid.yml")
        FileUtils.cp("config/project.yml.erb.example", "config/project.yml.erb")
        system!("BUNDLE_GEMFILE=#{Fontana.gemfile} bundle install")
      end
      Rake::Task["deploy:#{FontanaClientSupport.deploy_strategy}:reset"].delegate
    end

    task :update do
      Dir.chdir(FontanaClientSupport.vendor_fontana) do
        system!("git fetch origin")
        system!("git checkout origin/#{Fontana.branch}")
        system!("BUNDLE_GEMFILE=#{Fontana.gemfile} bundle install")
        system!("BUNDLE_GEMFILE=#{Fontana.gemfile} bundle exec rake db:drop")
      end
      Rake::Task["deploy:#{FontanaClientSupport.deploy_strategy}:update"].delegate
    end

    desc "reset vendor/fontana"
    task_sequential :reset, [:"vendor:fontana:clear", :"vendor:fontana:setup"]

    task :prepare do
      name = Dir.exist?(FontanaClientSupport.vendor_fontana) ? "update" : "reset"
      Rake::Task["vendor:fontana:#{name}"].delegate
    end
  end

end
