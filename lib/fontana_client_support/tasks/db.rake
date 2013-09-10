require 'fontana_client_support'
include Fontana::ServerRake
include Fontana::CommandUtils

tasks_without_desc = %w[drop seed summary create]
mongoid_tasks = %w[create_indexes remove_indexes]

[:development, :test].each do |app_mode|

  options = { env: { FONTANA_APP_MODE: app_mode.to_s } }
  namespace app_mode do
    namespace_with_fontana :db, :"db" do
      tasks_without_desc.each do |t|
        fontana_task t.to_sym, options
      end
    end

    namespace_with_fontana :db, :"db:mongoid" do
      mongoid_tasks.each do |t|
        fontana_task t.to_sym, options
      end
    end
  end
end

namespace :db do
  (tasks_without_desc + mongoid_tasks).each do |t|
    task t.to_sym => :"development:db:#{t}"
  end

  namespace :drop do
    if FontanaClientSupport.root_dir

      basename = File.basename(FontanaClientSupport.root_dir)
      db_names = `mongo --quiet --eval "db.adminCommand('listDatabases')['databases'].map(function(db){ return db.name }).filter(function(db){ return db.match(/#{basename}/)}).join(',')"`.strip.split(/,/)
      desc "CAUTION! drop databases: #{db_names.join(',')}"
      task :all do
        db_names.each do |db_name|
          system!(%Q!mongo --quiet --eval "db = db.getSiblingDB('#{db_name}'); printjson(db.dropDatabase())"!)
        end
      end

    else

      desc "CAUTION! drop databases for both development and test"
      task :all => [:"test:db:drop", :"development:db:drop"]

    end
  end
end



