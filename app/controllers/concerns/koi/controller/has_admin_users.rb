# frozen_string_literal: true

module Koi
  module Controller
    module HasAdminUsers
      extend ActiveSupport::Concern

      included do
        helper_method :admin_signed_in?
        helper_method :current_admin_user

        # @deprecated use current admin user instead
        helper_method :current_admin
      end

      def admin_signed_in?
        resume_admin_session

        Koi::Current.admin_user.present?
      end

      def current_admin_user
        resume_admin_session

        Koi::Current.admin_user
      end

      # @deprecated Use current_admin_user instead
      alias_method :current_admin, :current_admin_user

      def requires_session_authentication!
        head(:forbidden) unless resume_admin_session
      end

      # @return [Admin::Session, nil]
      def resume_admin_session
        Koi::Current.session ||= find_admin_session_by_cookie
      end

      # @return [Admin::Session, nil]
      def find_admin_session_by_cookie
        Admin::Session.find_by(id: cookies.signed[:admin_session_id]) if cookies.signed[:admin_session_id]
      end

      module Test
        # Include in view specs to stub out the current admin user
        module ViewHelper
          extend ActiveSupport::Concern

          included do
            before do
              view.singleton_class.module_eval do
                def admin_signed_in?
                  resume_admin_session.present?
                end

                def current_admin_user
                  resume_admin_session&.admin
                end

                alias_method :current_admin, :current_admin_user

                def resume_admin_session
                  Koi::Current.session ||= admin_user.sessions.new if respond_to?(:admin_user)
                end
              end
            end
          end
        end
      end
    end
  end
end
