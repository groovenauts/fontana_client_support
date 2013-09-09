puts "=" * 100

require 'fontana_client_support'
include Fontana::ServerRake

options = { before: ->{ ENV['FONTANA_ENV'] = app_mode.to_s.upcase } }

tasks_with_desc = %w[drop seed summary]
tasks_without_desc = %w[create]
mongoid_tasks = %w[create_indexes remove_indexes]

block = Proc.new do |app_mode|
  namespace_with_fontana :db, :"db" do

    tasks_with_desc.each do |task|
      desc "#{task} Database for #{app_mode}"
      fontana_task task.to_sym, options
    end

    tasks_without_desc.each do |task|
      fontana_task task.to_sym, options
    end
  end

  namespace_with_fontana :db, :"db:mongoid" do
    mongoid_tasks.each do |task|
      fontana_task task.to_sym, options
    end
  end

end


namespace(:test) do
  block.call(:test)
end

block.call(:development)


puts "*" * 100
