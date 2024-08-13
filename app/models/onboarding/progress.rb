# frozen_string_literal: true

module Onboarding
  class Progress < ApplicationRecord
    self.table_name = 'onboarding_progresses'

    include IgnorableColumns

    ignore_columns %i[
      git_pull_at
      subscription_created_at
      scoped_label_created_at
      security_scan_enabled_at
      issue_auto_closed_at
      repository_imported_at
      repository_mirrored_at
      secure_container_scanning_run_at
      secure_secret_detection_run_at
      secure_coverage_fuzzing_run_at
      secure_cluster_image_scanning_run_at
      secure_api_fuzzing_run_at
    ],
      remove_with: '17.5', remove_after: '2024-09-14'

    belongs_to :namespace, optional: false

    validate :namespace_is_root_namespace

    ACTIONS = [
      :git_write,
      :merge_request_created,
      :pipeline_created,
      :user_added,
      :trial_started,
      :required_mr_approvals_enabled,
      :code_owners_enabled,
      :issue_created,
      :secure_dependency_scanning_run,
      :secure_dast_run,
      :license_scanning_run,
      :code_added
    ].freeze

    scope :incomplete_actions, ->(actions) do
      Array.wrap(actions).inject(self) { |scope, action| scope.where(column_name(action) => nil) }
    end

    scope :completed_actions, ->(actions) do
      Array.wrap(actions).inject(self) { |scope, action| scope.where.not(column_name(action) => nil) }
    end

    scope :completed_actions_with_latest_in_range, ->(actions, range) do
      actions = Array(actions)
      if actions.size == 1
        where(column_name(actions[0]) => range)
      else
        action_columns = actions.map { |action| arel_table[column_name(action)] }
        completed_actions(actions).where(Arel::Nodes::NamedFunction.new('GREATEST', action_columns).between(range))
      end
    end

    class << self
      def onboard(namespace)
        return unless root_namespace?(namespace)

        create(namespace: namespace)
      end

      def onboarding?(namespace)
        where(namespace: namespace).any?
      end

      def register(namespace, actions)
        actions = Array(actions)
        return unless root_namespace?(namespace) && actions.difference(ACTIONS).empty?

        onboarding_progress = find_by(namespace: namespace)
        return unless onboarding_progress

        now = Time.current
        nil_actions = actions.select { |action| onboarding_progress[column_name(action)].nil? }
        return if nil_actions.empty?

        updates = nil_actions.inject({}) { |sum, action| sum.merge!({ column_name(action) => now }) }
        onboarding_progress.update(updates)
      end

      def completed?(namespace, action)
        return false unless root_namespace?(namespace) && ACTIONS.include?(action)

        action_column = column_name(action)
        where(namespace: namespace).where.not(action_column => nil).exists?
      end

      def not_completed?(namespace_id, action)
        return false unless ACTIONS.include?(action)

        action_column = column_name(action)
        exists?(namespace_id: namespace_id, action_column => nil)
      end

      def column_name(action)
        :"#{action}_at"
      end

      private

      def root_namespace?(namespace)
        namespace&.root?
      end
    end

    private

    def namespace_is_root_namespace
      return unless namespace

      errors.add(:namespace, _('must be a root namespace')) if namespace.has_parent?
    end
  end
end
