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

        if requires_authentication?(request) && !authenticated?(session)
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
        session[:admin_user_id].present?
      end
    end
  end
end
