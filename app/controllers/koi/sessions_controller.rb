# frozen_string_literal: true

module Koi
  class SessionsController < ApplicationController
    include Koi::Controller::HasWebauthn

    skip_before_action :authenticate_admin, only: %i[new create]

    layout "koi/login"

    def new
      return redirect_to dashboard_path if admin_signed_in?

      render :new, locals: { admin_user: AdminUser.new }
    end

    def create
      if (admin_user = webauthn_authenticate!)
        record_sign_in!(admin_user)

        session[:admin_user_id] = admin_user.id

        redirect_to dashboard_path, notice: "You have been logged in"
      elsif (admin_user = AdminUser.authenticate_by(session_params.slice(:email, :password)))
        record_sign_in!(admin_user)

        session[:admin_user_id] = admin_user.id

        redirect_to dashboard_path, notice: "You have been logged in"
      else
        admin_user = AdminUser.new(session_params.slice(:email, :password))
        admin_user.errors.add(:email, "Invalid email or password")

        render :new, status: :unprocessable_entity, locals: { admin_user: }
      end
    end

    def destroy
      record_sign_out!(current_admin_user)

      session[:admin_user_id] = nil

      redirect_to dashboard_path, notice: "You have been logged out"
    end

    private

    def session_params
      params.require(:admin).permit(:email, :password, :response)
    end

    def update_last_sign_in(admin_user)
      return if admin_user.current_sign_in_at.blank?

      admin_user.last_sign_in_at = admin_user.current_sign_in_at
      admin_user.last_sign_in_ip = admin_user.current_sign_in_ip
    end

    def record_sign_in!(admin_user)
      update_last_sign_in(admin_user)

      admin_user.current_sign_in_at = Time.current
      admin_user.current_sign_in_ip = request.remote_ip
      admin_user.sign_in_count      = admin_user.sign_in_count + 1

      admin_user.save!
    end

    def record_sign_out!(admin_user)
      update_last_sign_in(admin_user)

      admin_user.current_sign_in_at = nil
      admin_user.current_sign_in_ip = nil

      admin_user.save!
    end
  end
end
