# frozen_string_literal: true

module Admin
  class CredentialsController < ApplicationController
    include Koi::Controller::HasWebauthn

    layout "kpop"

    def new
      unless current_admin.webauthn_id
        current_admin.update!(webauthn_id: WebAuthn.generate_user_id)
      end

      options = webauthn_relying_party.options_for_registration(
        user:    {
          id:           current_admin.webauthn_id,
          name:         current_admin.email,
          display_name: current_admin.to_s,
        },
        exclude: current_admin.credentials.map(&:external_id),
      )

      # Store the newly generated challenge somewhere so you can have it
      # for the verification phase.
      session[:creation_challenge] = options.challenge

      render :new, locals: { options: }
    end

    def create
      redirect_to(action: :new) if session[:creation_challenge].blank?

      webauthn_credential = webauthn_relying_party.verify_registration(
        JSON.parse(credential_params[:response]),
        session.delete(:creation_challenge),
      )

      credential = current_admin.credentials.find_or_initialize_by(
        external_id: webauthn_credential.id,
      )

      credential.update!(
        nickname:   credential_params[:nickname],
        public_key: webauthn_credential.public_key,
        sign_count: webauthn_credential.sign_count,
      )

      respond_to do |format|
        format.html { redirect_to admin_admin_user_path(current_admin), status: :see_other }
        format.turbo_stream { render turbo_stream: turbo_stream.kpop.redirect_to(admin_admin_user_path(current_admin)) }
      end
    end

    def destroy
      credential = current_admin.credentials.find(params[:id])
      credential.destroy!

      redirect_to admin_admin_user_path(current_admin), status: :see_other
    end

    private

    def credential_params
      params.require(:admin_credential).permit(:nickname, :response)
    end
  end
end
