# frozen_string_literal: true

module Import
  class LoadPlaceholderReferencesWorker
    include ApplicationWorker

    data_consistency :delayed
    deduplicate :until_executed, if_deduplicated: :reschedule_once
    idempotent!
    feature_category :importers
    loggable_arguments 0, 1
    sidekiq_options retry: 6

    sidekiq_retries_exhausted do |msg, exception|
      new.perform_failure(exception, msg['args'].first, msg['args'].second)
    end

    def perform(import_source, import_uid, params = {})
      return unless Feature.enabled?(:importer_user_mapping, User.actor_from_id(params['current_user_id']))

      ::Import::PlaceholderReferences::LoadService.new(
        import_source: import_source,
        import_uid: import_uid
      ).execute
    end

    def perform_failure(exception, import_source, import_uid)
      fail_import(import_source, import_uid)

      ::Import::Framework::Logger.error(
        message: 'Failed to load all references to placeholder user contributions',
        error: exception.message,
        import_source: import_source,
        import_uid: import_uid
      )
    end

    private

    def fail_import(import_source, import_uid)
      import_state = nil

      case import_source
      when 'gitlab'
        import_state = BulkImport.find_by_id(import_uid)
      when 'github', 'bitbucket', 'bitbucket_server', 'fogbugz', 'gitea', 'gitlab_project'
        import_state = ProjectImportState.find_by_id(import_uid)
      when 'import_group_from_file'
        import_state = GroupImportState.find_by_group_id(import_uid)
      end

      import_state&.fail_op
    end
  end
end
