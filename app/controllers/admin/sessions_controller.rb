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
      if session_params[:response].present?
        create_session_with_webauthn
      elsif session_params[:token].present?
        create_session_with_token
      elsif session_params[:password].present?
        create_session_with_password
      elsif session_params[:email].present?
        # conversational flow, ask for password regardless of email
        admin_user = Admin::User.new(session_params.slice(:email))

        render(:password, status: :unprocessable_content, locals: { admin_user: })
      else
        # invalid request, re-render new
        admin_user = Admin::User.new

        render(:new, status: :unprocessable_content, locals: { admin_user: })
      end
    end

    def destroy
      record_sign_out!(current_admin_user)

      session[:admin_user_id] = nil

      redirect_to new_admin_session_path
    end

    private

    def create_session_with_password
      # constant time lookup for user with password verification
      admin_user = Admin::User.authenticate_by(session_params.slice(:email, :password))

      if admin_user.present? && admin_user.requires_otp?
        session[:pending_admin_user_id] = admin_user.id

        render(:otp, status: :unprocessable_content, locals: { admin_user: })
      elsif admin_user.present?
        admin_sign_in(admin_user)
      else
        admin_user = Admin::User.new(session_params.slice(:email, :password))
        admin_user.errors.add(:email, :invalid)

        render(:new, status: :unprocessable_content, locals: { admin_user: })
      end
    end

    def create_session_with_token
      # assume that the previous step injected the user's ID into the session and remove it regardless of outcome
      admin_user = Admin::User.find_by(id: session.delete(:pending_admin_user_id))

      if admin_user&.otp&.verify(session_params[:token],
                                 drift_ahead:  15,
                                 drift_behind: 15,
                                 after:        admin_user.current_sign_in_at)
        admin_sign_in(admin_user)
      else
        admin_user = Admin::User.new
        admin_user.errors.add(:email, :invalid)

        render(:new, status: :unprocessable_content, locals: { admin_user: })
      end
    end

    def create_session_with_webauthn
      if (admin_user = webauthn_authenticate!)
        admin_sign_in(admin_user)
      else
        admin_user = Admin::User.new
        admin_user.errors.add(:email, :invalid)

        render(:new, status: :unprocessable_content, locals: { admin_user: })
      end
    end

    def redirect_authenticated
      redirect_to(admin_dashboard_path, status: :see_other)
    end

    def admin_sign_in(admin_user)
      record_sign_in!(admin_user)

      session[:admin_user_id] = admin_user.id

      redirect_to(url_from(params[:redirect].presence) || admin_dashboard_path, status: :see_other)
    end

    def session_params
      params.expect(admin: %i[email password token response])
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
