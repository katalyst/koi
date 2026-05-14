# frozen_string_literal: true

module Koi
  module Controller
    module RecordsAuthentication
      ADMIN_SESSION_COOKIE = :koi_admin_session_id

      def create_admin_session!(admin_user = Koi::Current.admin_user)
        admin_user.sign_in_count += 1
        admin_user.save!

        Koi::Current.admin_session = admin_user.sessions.create!(
          ip_address: request.remote_ip,
          user_agent: request.user_agent,
        )

        cookies.signed.permanent[ADMIN_SESSION_COOKIE] = {
          value:     Koi::Current.admin_session.id,
          httponly:  true,
          same_site: :lax,
        }
      end

      def destroy_admin_session!
        Koi::Current.admin_session&.destroy!
        Koi::Current.admin_session = nil

        cookies.delete(ADMIN_SESSION_COOKIE)
      end
    end
  end
end
