# frozen_string_literal: true

module Admin
  class PasskeyResetsController < ApplicationController
    include Koi::Controller::HasWebauthn

    skip_before_action :authenticate_admin, only: %i[new create edit update]
    before_action :set_admin_user, only: %i[edit update]

    layout "koi/login"

    def new
      render :new, locals: { admin_user: Admin::User.new }
    end

    def create
      if (admin_user = Admin::User.find_by(email: passkey_reset_params[:email]))
        # remove previous passkeys
        admin_user.credentials.destroy_all

        token = admin_user.generate_token_for(:passkey_reset_token)
        PasskeyResetMailer.passkey_reset(user: admin_user, token:).deliver_now!
      end

      redirect_to new_admin_session_path, notice: "A passkey reset email sent, check your email."
    end

    def edit
      return redirect_to new_admin_session_path, notice: "Reset link expired." if @admin_user.blank?

      options = webauthn_relying_party.options_for_registration(
        user:    {
          id:           WebAuthn.generate_user_id,
          name:         @admin_user.email,
          display_name: @admin_user.to_s,
        },
        exclude: @admin_user.credentials.map(&:external_id),
      )

      # Store the newly generated challenge somewhere so you can have it
      # for the verification phase.
      session[:creation_challenge] = options.challenge

      render :edit, locals: { admin_user: @admin_user, options: }
    end

    def update
      webauthn_credential = webauthn_relying_party.verify_registration(
        JSON.parse(passkey_reset_params[:response]),
        session.delete(:creation_challenge),
      )

      credential = @admin_user.credentials.build(
        nickname:    passkey_reset_params[:nickname],
        public_key:  webauthn_credential.public_key,
        sign_count:  webauthn_credential.sign_count,
        external_id: webauthn_credential.id,
      )

      credential.save!

      redirect_to new_admin_session_path, notice: "Please login using new passkey!"
    end

    private

    def set_admin_user
      @admin_user = Admin::User.find_by_token_for(:passkey_reset_token, params[:token])
    end

    def passkey_reset_params
      params.require(:admin).permit(:email, :nickname, :response)
    end
  end
end
