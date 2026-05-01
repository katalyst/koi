# frozen_string_literal: true

module Koi
  module Middleware
    class AdminAuthentication
      def initialize(app)
        @app = app
      end

      def call(env)
        if env["PATH_INFO"].starts_with?("/admin")
          admin_call(env)
        else
          @app.call(env)
        end
      end

      def admin_call(env)
        request = ActionDispatch::Request.new(env)
        session = ActionDispatch::Request::Session.find(request)
        authenticated = authenticated?(session)

        if requires_authentication?(request) && !authenticated
          # Set the redirection path for returning the user to their requested path after login
          if request.get?
            request.flash[:redirect] = request.fullpath
            request.commit_flash
          end

          [303, { "Location" => "/admin/session/new" }, []]
        else
          @app.call(env)
        end
      end

      private

      def requires_authentication?(request)
        !request.path.starts_with?("/admin/session")
      end

      def authenticated?(session)
        admin_user = Admin::User.find_by(id: session[:admin_user_id])
        unless admin_user
          clear_admin_session(session)
          return false
        end

        signed_in_at = session_signed_in_at(session)
        if signed_in_at.blank? || session_expired?(admin_user, signed_in_at)
          clear_admin_session(session)
          return false
        end

        true
      end

      def session_signed_in_at(session)
        Time.zone.parse(session[:admin_user_signed_in_at].to_s)
      rescue ArgumentError
        nil
      end

      def session_expired?(admin_user, signed_in_at)
        admin_user.last_sign_out_at.present? && signed_in_at < admin_user.last_sign_out_at
      end

      def clear_admin_session(session)
        session.delete(:admin_user_id)
        session.delete(:admin_user_signed_in_at)
      end
    end
  end
end
