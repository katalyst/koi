# frozen_string_literal: true

module Koi
  module Controller
    module HasWebauthn
      extend ActiveSupport::Concern

      included do
        helper Helper
      end

      def webauthn_relying_party
        @webauthn_relying_party ||=
          WebAuthn::RelyingParty.new(
            name:            Koi.config.admin_name,
            allowed_origins: [request.base_url],
          )
      end

      module Helper
        def webauthn_authentication_options_value
          options = controller.webauthn_relying_party.options_for_authentication

          session[:authentication_challenge] = options.challenge

          options
        end

        def webauthn_registration_options_value
          user = current_admin_user.tap do |u|
            u.update!(webauthn_id: WebAuthn.generate_user_id) unless u.webauthn_id
          end

          options = controller.webauthn_relying_party.options_for_registration(
            user:    {
              id:           user.webauthn_id,
              name:         user.email,
              display_name: user.name,
            },
            exclude: user.credentials.pluck(:external_id),
          )

          session[:registration_challenge] = options.challenge

          options
        end
      end

      def webauthn_authenticate!(response)
        return if response.blank?

        webauthn_credential, stored_credential = webauthn_relying_party.verify_authentication(
          JSON.parse(response),
          session.delete(:authentication_challenge),
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

      def webauthn_register!(response)
        return if response.blank?

        webauthn_credential = webauthn_relying_party.verify_registration(
          JSON.parse(response),
          session.delete(:registration_challenge),
        )

        current_admin_user
          .credentials
          .create_with(nickname:   webauthn_nickname,
                       public_key: webauthn_credential.public_key,
                       sign_count: webauthn_credential.sign_count)
          .create_or_find_by!(
            external_id: webauthn_credential.id,
          )
      end

      def webauthn_nickname
        user_agent = UserAgent.parse(request.user_agent)
        "#{user_agent.browser} (#{user_agent.platform})"
      end
    end
  end
end
