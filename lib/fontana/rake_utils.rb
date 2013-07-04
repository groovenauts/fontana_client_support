require 'fontana'

module Fontana
  module RakeUtils

    module_function

    def call(task_name)
      task = Rake::Task[task_name]
      pp task.prerequisites
    end
  end
end
