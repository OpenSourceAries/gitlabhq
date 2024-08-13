# frozen_string_literal: true

module Projects
  module Security
    class ConfigurationPresenter < Gitlab::View::Presenter::Delegated
      include AutoDevopsHelper
      include ::Security::LatestPipelineInformation

      presents ::Project, as: :project

      def to_h
        {
          auto_devops_enabled: auto_devops_source?,
          auto_devops_help_page_path: help_page_path('topics/autodevops/index'),
          auto_devops_path: auto_devops_settings_path(project),
          can_enable_auto_devops: can_enable_auto_devops?,
          features: features,
          help_page_path: help_page_path('user/application_security/index'),
          latest_pipeline_path: latest_pipeline_path,
          gitlab_ci_present: project.has_ci_config_file?,
          gitlab_ci_history_path: gitlab_ci_history_path,
          security_training_enabled: project.security_training_available?,
          container_scanning_for_registry_enabled: container_scanning_for_registry_enabled,
          pre_receive_secret_detection_available:
            Gitlab::CurrentSettings.current_application_settings.pre_receive_secret_detection_enabled,
          pre_receive_secret_detection_enabled: pre_receive_secret_detection_enabled,
          user_is_project_admin: user_is_project_admin?
        }
      end

      def to_html_data_attribute
        data = to_h
        data[:features] = data[:features].to_json

        data
      end

      private

      def can_enable_auto_devops?
        feature_available?(:builds, current_user) &&
          user_is_project_admin? &&
          !archived?
      end

      def user_is_project_admin?
        can?(current_user, :admin_project, self)
      end

      def gitlab_ci_history_path
        return '' if project.empty_repo?

        ::Gitlab::Routing.url_helpers.project_blame_path(
          project, File.join(project.default_branch_or_main, project.ci_config_path_or_default))
      end

      def features
        scans = scan_types.map do |scan_type|
          scan(scan_type, configured: scanner_enabled?(scan_type))
        end

        # These scans are "fake" (non job) entries. Add them manually.
        scans << scan(:corpus_management, configured: true)
        scans << scan(:dast_profiles, configured: true)

        # Add pre-receive before secret detection
        if dedicated_instance? || pre_receive_secret_detection_feature_flag_enabled?
          secret_detection_index = scans.index { |scan| scan[:type] == :secret_detection } || -1
          scans.insert(secret_detection_index, scan(:pre_receive_secret_detection, configured: true))
        end

        scans
      end

      def latest_pipeline_path
        return help_page_path('ci/pipelines/index') unless latest_default_branch_pipeline

        project_pipeline_path(self, latest_default_branch_pipeline)
      end

      def scan(type, configured: false)
        scan = ::Gitlab::Security::ScanConfiguration.new(project: project, type: type, configured: configured)

        {
          type: scan.type,
          configured: scan.configured?,
          configuration_path: scan.configuration_path,
          available: scan.available?,
          can_enable_by_merge_request: scan.can_enable_by_merge_request?,
          meta_info_path: scan.meta_info_path,
          on_demand_available: scan.on_demand_available?,
          security_features: scan.security_features
        }
      end

      def scan_types
        ::Security::SecurityJobsFinder.allowed_job_types + ::Security::LicenseComplianceJobsFinder.allowed_job_types
      end

      def dedicated_instance?
        ::Gitlab::CurrentSettings.gitlab_dedicated_instance?
      end

      def pre_receive_secret_detection_feature_flag_enabled?
        return false unless project.licensed_feature_available?(:pre_receive_secret_detection)

        Feature.enabled?(:pre_receive_secret_detection_beta_release) && Feature.enabled?(
          :pre_receive_secret_detection_push_check, project)
      end

      def project_settings
        project.security_setting
      end

      def container_scanning_for_registry_enabled; end
      def pre_receive_secret_detection_enabled; end
    end
  end
end

Projects::Security::ConfigurationPresenter.prepend_mod_with('Projects::Security::ConfigurationPresenter')
