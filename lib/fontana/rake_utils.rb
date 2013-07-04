require 'fontana'

module Fontana
  module RakeUtils

    class << self
      def enable_task_delegate
        unless Rake::Task.ancestors.include?(Fontana::RakeUtils::Delegatable)
          Rake::Task.send(:include, Fontana::RakeUtils::Delegatable)
        end
      end
    end

    module Delegatable
      def delegate
        self.prerequisite_tasks.each(&:delegate)
        execute
      end
    end

    def task_sequential(name, task_names)
      Fontana::RakeUtils.enable_task_delegate
      task(name) do
        task_names.each do |name|
          Rake::Task[name.to_s].delegate
        end
      end
    end
  end
end
