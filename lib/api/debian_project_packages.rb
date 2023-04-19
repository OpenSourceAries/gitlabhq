# frozen_string_literal: true

module API
  class DebianProjectPackages < ::API::Base
    PACKAGE_FILE_REQUIREMENTS = {
      id: API::NO_SLASH_URL_PART_REGEX,
      distribution: ::Packages::Debian::DISTRIBUTION_REGEX,
      letter: ::Packages::Debian::LETTER_REGEX,
      package_name: API::NO_SLASH_URL_PART_REGEX,
      package_version: API::NO_SLASH_URL_PART_REGEX,
      file_name: API::NO_SLASH_URL_PART_REGEX
    }.freeze
    FILE_NAME_REQUIREMENTS = {
      file_name: API::NO_SLASH_URL_PART_REGEX
    }.freeze

    resource :projects, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
      helpers do
        def project_or_group
          user_project(action: :read_package)
        end
      end

      after_validation do
        require_packages_enabled!

        not_found! unless ::Feature.enabled?(:debian_packages, project_or_group)

        authorize_read_package!(project_or_group)
      end

      params do
        requires :id, types: [String, Integer], desc: 'The ID or URL-encoded path of the project'
      end

      namespace ':id/packages/debian' do
        include ::API::Concerns::Packages::DebianPackageEndpoints

        # GET projects/:id/packages/debian/pool/:distribution/:letter/:package_name/:package_version/:file_name
        params do
          use :shared_package_file_params
        end

        desc 'Download Debian package' do
          detail 'This feature was introduced in GitLab 14.2'
          success code: 200
          failure [
            { code: 401, message: 'Unauthorized' },
            { code: 403, message: 'Forbidden' },
            { code: 404, message: 'Not Found' }
          ]
          tags %w[debian_packages]
        end

        route_setting :authentication, authenticate_non_public: true
        get 'pool/:distribution/:letter/:package_name/:package_version/:file_name', requirements: PACKAGE_FILE_REQUIREMENTS do
          present_distribution_package_file!(project_or_group)
        end

        params do
          requires :file_name, type: String, desc: 'The file name', documentation: { example: 'example_1.0.0~alpha2_amd64.deb' }
        end

        namespace ':file_name', requirements: FILE_NAME_REQUIREMENTS do
          format :txt
          content_type :json, Gitlab::Workhorse::INTERNAL_API_CONTENT_TYPE

          # PUT {projects|groups}/:id/packages/debian/:file_name
          desc 'Upload Debian package' do
            detail 'This feature was introduced in GitLab 14.0'
            success code: 201
            failure [
              { code: 400, message: 'Bad Request' },
              { code: 401, message: 'Unauthorized' },
              { code: 403, message: 'Forbidden' },
              { code: 404, message: 'Not Found' }
            ]
            tags %w[debian_packages]
          end
          params do
            requires :file, type: ::API::Validations::Types::WorkhorseFile, desc: 'The package file to be published (generated by Multipart middleware)', documentation: { type: 'file' }
            optional :distribution, type: String, desc: 'The Debian Codename or Suite', regexp: Gitlab::Regex.debian_distribution_regex
            given :distribution do
              requires :component, type: String, desc: 'The Debian Component', regexp: Gitlab::Regex.debian_component_regex
              requires :file_name, type: String, desc: 'The filename', regexp: { value: Gitlab::Regex.debian_direct_upload_filename_regex, message: 'Only debs, udebs and ddebs can be directly added to a distribution' }
            end
          end
          route_setting :authentication, deploy_token_allowed: true, basic_auth_personal_access_token: true, job_token_allowed: :basic_auth, authenticate_non_public: true
          put do
            authorize_upload!(authorized_user_project)
            bad_request!('File is too large') if authorized_user_project.actual_limits.exceeded?(:debian_max_file_size, params[:file].size)

            file_params = {
              file: params['file'],
              file_name: params['file_name'],
              file_sha1: params['file.sha1'],
              file_md5: params['file.md5'],
              distribution: params['distribution'],
              component: params['component']
            }

            package = if params[:distribution].present?
                        ::Packages::CreateTemporaryPackageService.new(
                          authorized_user_project, current_user, declared_params.merge(build: current_authenticated_job)
                        ).execute(:debian, name: ::Packages::Debian::TEMPORARY_PACKAGE_NAME)
                      else
                        ::Packages::Debian::FindOrCreateIncomingService.new(authorized_user_project, current_user).execute
                      end

            ::Packages::Debian::CreatePackageFileService.new(package: package, current_user: current_user, params: file_params).execute

            track_debian_package_event 'push_package'

            created!
          rescue ObjectStorage::RemoteStoreError => e
            Gitlab::ErrorTracking.track_exception(e, extra: { file_name: params[:file_name], project_id: authorized_user_project.id })

            forbidden!
          end

          # PUT {projects|groups}/:id/packages/debian/:file_name/authorize
          desc 'Authorize Debian package upload' do
            detail 'This feature was introduced in GitLab 13.5'
            success code: 200
            failure [
              { code: 400, message: 'Bad Request' },
              { code: 401, message: 'Unauthorized' },
              { code: 403, message: 'Forbidden' },
              { code: 404, message: 'Not Found' }
            ]
            tags %w[debian_packages]
          end
          params do
            optional :distribution, type: String, desc: 'The Debian Codename or Suite', regexp: Gitlab::Regex.debian_distribution_regex
            given :distribution do
              requires :component, type: String, desc: 'The Debian Component', regexp: Gitlab::Regex.debian_component_regex
              requires :file_name, type: String, desc: 'The filename', regexp: { value: Gitlab::Regex.debian_direct_upload_filename_regex, message: 'Only debs, udebs and ddebs can be directly added to a distribution' }
            end
          end
          route_setting :authentication, deploy_token_allowed: true, basic_auth_personal_access_token: true, job_token_allowed: :basic_auth, authenticate_non_public: true
          put 'authorize' do
            authorize_workhorse!(
              subject: authorized_user_project,
              maximum_size: authorized_user_project.actual_limits.debian_max_file_size
            )
          end
        end
      end
    end
  end
end
