# frozen_string_literal: true

module Admin
  class TokensController < ApplicationController
    include Koi::Controller::JsonWebToken

    skip_before_action :authenticate_admin, only: %i[show update]
    before_action :set_token, only: %i[show update]

    def create
      admin = Admin::User.find(params[:id])
      token = encode_token(admin_id: admin.id, exp: 5.minutes.from_now.to_i, iat: Time.now.to_i)

      render locals: { token: }
    end

    def update
      return redirect_to admin_dashboard_path, status: :see_other if admin_signed_in?

      return redirect_to new_admin_session_path, status: :see_other, notice: "invalid token" if @token.blank?

      admin = Admin::User.find(@token[:admin_id])
      sign_in_admin(admin)

      redirect_to admin_admin_user_path(admin)
    end

    def show
      return redirect_to new_admin_session_path, notice: "Token invalid or consumed already" if @token.blank?

      admin = Admin::User.find(@token[:admin_id])

      if token_utilised?(admin, @token)
        return redirect_to new_admin_session_path, notice: "Token invalid or consumed already"
      end

      render locals: { admin:, token: params[:token] }, layout: "koi/login"
    end

    private

    def set_token
      @token = decode_token(params[:token])
    end

    def token_utilised?(admin, token)
      admin.current_sign_in_at.present? || (admin.last_sign_in_at.present? && admin.last_sign_in_at.to_i > token[:iat])
    end

    def sign_in_admin(admin)
      admin.current_sign_in_at = Time.current
      admin.current_sign_in_ip = request.remote_ip
      admin.sign_in_count      = 1

      # disable validations to allow saving without password or passkey credentials
      admin.save!(validate: false)
      session[:admin_user_id] = admin.id
    end
  end
end
