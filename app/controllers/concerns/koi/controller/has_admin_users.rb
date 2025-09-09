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
        current_admin_user.present?
      rescue ActiveRecord::RecordNotFound
        false
      end

      def current_admin_user
        return @current_admin_user if instance_variable_defined?(:@current_admin_user)
        return @current_admin_user = nil unless session.has_key?(:admin_user_id)

        @current_admin_user = Admin::User.find(session[:admin_user_id])
      ensure
        session.delete(:admin_user_id) unless @current_admin_user
      end

      # @deprecated Use current_admin_user instead
      alias_method :current_admin, :current_admin_user

      module Test
        # Include in view specs to stub out the current admin user
        module ViewHelper
          extend ActiveSupport::Concern

          included do
            before do
              view.singleton_class.module_eval do
                def admin_signed_in?
                  current_admin_user.present?
                end

                def current_admin_user
                  respond_to?(:admin_user) ? admin_user : nil
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
