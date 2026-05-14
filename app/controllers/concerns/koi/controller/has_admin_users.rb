# frozen_string_literal: true

module Koi
  module Controller
    module HasAdminUsers
      extend ActiveSupport::Concern

      included do
        helper_method :admin_signed_in?
        helper_method :current_admin_user
        before_action :set_koi_admin_session, unless: :koi_admin_controller?

        # @deprecated use current admin user instead
        helper_method :current_admin
      end

      def admin_signed_in?
        Koi::Current.admin_user.present?
      end

      def current_admin_user
        Koi::Current.admin_user
      end

      def set_koi_admin_session
        return if Koi::Current.admin_session.present? || Koi::Current.admin_user.present?

        Koi::Current.admin_session = Admin::Session.from_request(request)
      end

      def koi_admin_controller?
        self.class < Admin::ApplicationController
      end

      # @deprecated Use current_admin_user instead
      alias_method :current_admin, :current_admin_user

      def requires_session_authentication!
        head(:forbidden) if Koi::Current.admin_session.blank?
      end

      module Test
        # Include in view specs to stub out the current admin user
        module ViewHelper
          extend ActiveSupport::Concern

          included do
            before do
              view.singleton_class.module_eval do
                def admin_signed_in?
                  Koi::Current.admin_user.present?
                end

                def current_admin_user
                  Koi::Current.admin_user = (respond_to?(:admin_user) ? admin_user : nil)
                end

                alias_method :current_admin, :current_admin_user
              end
            end
          end
        end
      end
    end
  end
end
