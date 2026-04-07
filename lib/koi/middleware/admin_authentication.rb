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

        # Always retrieve user to ensure we are not vulnerable to timing attacks
        Koi::Current.admin_user = Admin::User.find_by(id: session[:admin_user_id])

        # Remove from session if not found
        session.delete(:admin_user_id) if session.has_key?(:admin_user_id) && !authenticated?

        if requires_authentication?(request) && !authenticated?
          # Set the redirection path for returning the user to their requested path after login
          if request.get?
            request.flash[:redirect] = request.fullpath
            request.commit_flash
          end

          [303, { "Location" => "/admin/session/new" }, []]
        else
          @app.call(env)
        end
      ensure
        Koi::Current.admin_user = nil
      end

      private

      def requires_authentication?(request)
        !request.path.starts_with?("/admin/session")
      end

      def authenticated?
        Koi::Current.admin_user.present?
      end
    end
  end
end
