# frozen_string_literal: true

module Admin
  class TokensController < ApplicationController
    include Koi::Controller::JsonWebToken

    before_action :set_admin, only: %i[create]
    before_action :set_token, only: %i[show update]
    before_action :invalid_token, only: %i[show update], unless: :token_valid?

    def show
      render locals: { admin: @admin, token: params[:token] }, layout: "koi/login"
    end

    def create
      token = encode_token(admin_id: @admin.id, exp: 30.minutes.from_now.to_i, iat: Time.current.to_i)

      render locals: { token: }
    end

    def update
      sign_in_admin(@admin)

      redirect_to admin_admin_user_path(@admin), status: :see_other, notice: t("koi.auth.token_consumed")
    end

    private

    def set_admin
      @admin = Admin::User.find(params[:admin_user_id])
    end

    def set_token
      @token = decode_token(params[:token])

      # constant time token validation requires that we always try to retrieve a user
      @admin = Admin::User.find_by(id: @token&.fetch(:admin_id) || "")
    end

    def token_valid?
      return false unless @token.present? && @admin.present?

      # Ensure that the user has not signed in since the token was generated
      if @admin.current_sign_in_at.present?
        @admin.current_sign_in_at.to_i < @token[:iat]
      elsif @admin.last_sign_in_at.present?
        @admin.last_sign_in_at.to_i < @token[:iat]
      else
        true # first sign in
      end
    end

    def invalid_token
      redirect_to(new_admin_session_path, status: :see_other, notice: I18n.t("koi.auth.token_invalid"))
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
