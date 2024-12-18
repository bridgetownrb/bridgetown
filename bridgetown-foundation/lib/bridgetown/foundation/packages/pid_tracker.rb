# frozen_string_literal: true

module Bridgetown::Foundation
  module Packages
    module PidTracker
      def create_pid_dir
        FileUtils.mkdir_p pids_dir
      end

      def add_pid(pid, file:)
        File.write pidfile_for(file), "#{pid}\n", mode: "a+"
      end

      def read_pidfile(file)
        File.readlines pidfile_for(file), chomp: true
      rescue SystemCallError
        []
      end

      def remove_pidfile(file)
        File.delete pidfile_for(file)
      rescue SystemCallError # rubocop:disable Lint/SuppressedException
      end

      private

      def root_dir
        Dir.pwd
      end

      def pids_dir
        File.join(root_dir, "tmp", "pids")
      end

      def pidfile_for(file)
        File.join(pids_dir, "#{file}.pid")
      end
    end
  end
end
