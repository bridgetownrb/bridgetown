# frozen_string_literal: true

module Bridgetown
  module Commands
    module GitHelpers
      def initialize_new_repo
        run "git init", abort_on_failure: true
        `git symbolic-ref HEAD refs/heads/main` if user_default_branch.empty?
      end

      def destroy_existing_repo
        run "rm -rf .git"
      end

      def user_default_branch
        @user_default_branch ||= `git config init.defaultbranch`.strip
      end
    end
  end
end
