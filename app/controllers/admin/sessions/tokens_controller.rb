# frozen_string_literal: true

module Admin
  module Sessions
    class TokensController < ApplicationController
      include Koi::Controller::RecordsAuthentication

      attr_reader :admin_user

      def show
        if (@admin_user = Admin::User.find_by_token_for(:password_reset, params[:token]))
          render locals: { admin_user:, token: params[:token] }
        else
          redirect_to(new_admin_session_path, status: :see_other, notice: I18n.t("koi.auth.token_invalid"))
        end
      end

      def update
        if (@admin_user = Admin::User.find_by_token_for(:password_reset, params[:token]))
          create_admin_session!(admin_user)

          if admin_user.credentials.any?
            redirect_to(admin_root_path, status: :see_other)
          else
            redirect_to(new_admin_profile_credential_path, status: :see_other)
          end
        else
          redirect_to(new_admin_session_path, status: :see_other, notice: I18n.t("koi.auth.token_invalid"))
        end
      end
    end
  end
end
