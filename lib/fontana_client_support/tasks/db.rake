require 'fontana_client_support'
include Fontana::ServerRake


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
end
