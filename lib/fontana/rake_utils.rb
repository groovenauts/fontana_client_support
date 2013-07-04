require 'fontana'

module Fontana
  module RakeUtils

    class << self
      def enable_task_delegate
        Rake::Task.send(:include, Fontana::RakeUtils::Delegatable)
      end
    end

    module Delegatable
      def delegate
        self.prerequisite_tasks.each(&:delegate)
        execute
      end
    end

  end
end
