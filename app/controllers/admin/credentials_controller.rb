# frozen_string_literal: true

module Admin
  class CredentialsController < ApplicationController
    include Koi::Controller::HasWebauthn

    before_action :set_admin_user

    def new
      unless @admin_user.webauthn_id
        @admin_user.update!(webauthn_id: WebAuthn.generate_user_id)
      end

      options = webauthn_relying_party.options_for_registration(
        user:    {
          id:           @admin_user.webauthn_id,
          name:         @admin_user.email,
          display_name: @admin_user.to_s,
        },
        exclude: @admin_user.credentials.map(&:external_id),
      )

      # Store the newly generated challenge somewhere so you can have it
      # for the verification phase.
      session[:creation_challenge] = options.challenge

      render :new, locals: { admin: @admin_user, options: }
    end

    def create
      redirect_to(action: :new) if session[:creation_challenge].blank?

      webauthn_credential = webauthn_relying_party.verify_registration(
        JSON.parse(credential_params[:response]),
        session.delete(:creation_challenge),
      )

      credential = @admin_user.credentials.find_or_initialize_by(
        external_id: webauthn_credential.id,
      )

      credential.update!(
        nickname:   credential_params[:nickname],
        public_key: webauthn_credential.public_key,
        sign_count: webauthn_credential.sign_count,
      )

      respond_to do |format|
        format.html { redirect_to admin_admin_user_path(@admin_user), status: :see_other }
        format.turbo_stream { render locals: { admin: @admin_user } }
      end
    end

    def destroy
      credential = @admin_user.credentials.find(params[:id])
      credential.destroy!

      respond_to do |format|
        format.html { redirect_to admin_admin_user_path(@admin_user), status: :see_other }
        format.turbo_stream { render locals: { admin: @admin_user } }
      end
    end

    private

    def credential_params
      params.expect(admin_credential: %i[nickname response])
    end

    def set_admin_user
      @admin_user = Admin::User.find(params[:admin_user_id])

      if current_admin == @admin_user
        request.variant = :self
      else
        head(:forbidden)
      end
    end
  end
end
