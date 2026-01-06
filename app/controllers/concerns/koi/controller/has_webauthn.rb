# frozen_string_literal: true

module Koi
  module Controller
    module HasWebauthn
      extend ActiveSupport::Concern

      included do
        helper_method :webauthn_auth_options
      end

      def webauthn_relying_party
        @webauthn_relying_party ||=
          WebAuthn::RelyingParty.new(
            name:            Koi.config.admin_name,
            allowed_origins: [request.base_url],
          )
      end

      def webauthn_auth_options
        options = webauthn_relying_party.options_for_authentication

        session[:authentication_challenge] = options.challenge

        options
      end

      def webauthn_authenticate!
        return if session_params[:response].blank?

        webauthn_credential, stored_credential = webauthn_relying_party.verify_authentication(
          JSON.parse(session_params[:response]),
          session[:authentication_challenge],
        ) do |credential|
          Admin::Credential.find_by!(external_id: credential.id)
        end

        stored_credential.update(
          sign_count: webauthn_credential.sign_count,
          updated_at: DateTime.current,
        )

        stored_credential.admin
      rescue ActiveRecord::RecordNotFound, WebAuthn::VerificationError
        false
      end
    end
  end
end
