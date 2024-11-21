# frozen_string_literal: true

module Admin
  class SessionsController < ApplicationController
    include Koi::Controller::HasWebauthn

    before_action :redirect_authenticated, only: %i[new], if: :admin_signed_in?
    before_action :authenticate_local_admin, only: %i[new], if: :authenticate_local_admins?

    layout "koi/login"

    def new
      render locals: { admin_user: Admin::User.new }
    end

    def create
      if (admin_user = webauthn_authenticate! || params_authenticate!)
        record_sign_in!(admin_user)

        session[:admin_user_id] = admin_user.id

        redirect_to(url_from(params[:redirect].presence) || admin_dashboard_path, status: :see_other)
      else
        admin_user = Admin::User.new(session_params.slice(:email, :password))
        admin_user.errors.add(:email, "Invalid email or password")

        render(:new, status: :unprocessable_content, locals: { admin_user: })
      end
    end

    def destroy
      record_sign_out!(current_admin_user)

      session[:admin_user_id] = nil

      redirect_to new_admin_session_path
    end

    private

    def redirect_authenticated
      redirect_to(admin_dashboard_path, status: :see_other)
    end

    def session_params
      params.require(:admin).permit(:email, :password, :response)
    end

    def params_authenticate!
      Admin::User.authenticate_by(session_params.slice(:email, :password))
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
      return unless admin_user

      update_last_sign_in(admin_user)

      admin_user.current_sign_in_at = nil
      admin_user.current_sign_in_ip = nil

      admin_user.save!
    end
  end
end
