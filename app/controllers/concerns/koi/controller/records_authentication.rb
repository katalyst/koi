# frozen_string_literal: true

module Koi
  module Controller
    module RecordsAuthentication
      def create_admin_session!(admin_user)
        admin_user.sessions.create!(
          user_agent: request.user_agent,
          ip_address: request.remote_ip,
        ).tap do |session|
          Koi::Current.session                        = session
          cookies.signed.permanent[:admin_session_id] = { value: session.id, httponly: true, same_site: :lax }
        end
      end

      def destroy_admin_sessions!(admin_user)
        admin_user.device_authorizations.destroy_all
        admin_user.sessions.destroy_all

        Koi::Current.session = nil
        cookies.delete(:admin_session_id)
      end
    end
  end
end
