# frozen_string_literal: true

module Koi
  module Controller
    module RecordsAuthentication
      def create_admin_session!(admin_user = Koi::Current.admin_user)
        admin_user.sign_in_count += 1
        admin_user.save!

        Koi::Current.admin_session = admin_user.sessions.create!(
          ip_address: request.remote_ip,
          user_agent: request.user_agent,
        )

        cookies.signed.permanent[Admin::Session::COOKIE_NAME] = {
          value:     Koi::Current.admin_session.id,
          httponly:  true,
          same_site: :lax,
        }
      end

      def destroy_admin_session!
        Koi::Current.admin_session&.destroy!
        Koi::Current.admin_session = nil
        Koi::Current.admin_user    = nil

        cookies.delete(Admin::Session::COOKIE_NAME)
      end
    end
  end
end
