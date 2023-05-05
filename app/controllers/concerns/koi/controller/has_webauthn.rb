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
            name:   "Koi Admin",
            origin: request.base_url,
          )
      end

      def webauthn_auth_options
        options                            = webauthn_relying_party.options_for_authentication(
          allow: AdminCredential.pluck(:external_id),
        )
        session[:authentication_challenge] = options.challenge

        options
      end

      def webauthn_authenticate!
        return if session_params[:response].blank?

        webauthn_credential, stored_credential = webauthn_relying_party.verify_authentication(
          JSON.parse(session_params[:response]),
          session[:authentication_challenge],
        ) do |credential|
          AdminCredential.find_by!(external_id: credential.id)
        end

        stored_credential.update!(sign_count: webauthn_credential.sign_count)

        stored_credential.admin
      end
    end
  end
end
