# frozen_string_literal: true

module Admin
  class TokensController < ApplicationController
    include Koi::Controller::RecordsAuthentication

    before_action :set_admin_user, only: %i[create]

    attr_reader :admin_user

    def show
      if (@admin_user = Admin::User.find_by_token_for(:password_reset, params[:token]))
        render locals: { admin_user:, token: params[:token] }
      else
        redirect_to(new_admin_session_path, status: :see_other, notice: I18n.t("koi.auth.token_invalid"))
      end
    end

    def create
      render locals: { token: admin_user.generate_token_for(:password_reset) }
    end

    def update
      if (@admin_user = Admin::User.find_by_token_for(:password_reset, params[:token]))
        record_sign_in!(admin_user)

        session[:admin_user_id] = admin_user.id

        if admin_user.credentials.any?
          redirect_to(admin_root_path, status: :see_other)
        else
          redirect_to(new_admin_admin_user_credential_path(admin_user), status: :see_other)
        end
      else
        redirect_to(new_admin_session_path, status: :see_other, notice: I18n.t("koi.auth.token_invalid"))
      end
    end

    private

    def set_admin_user
      @admin_user = Admin::User.find(params[:admin_user_id])
    end
  end
end
