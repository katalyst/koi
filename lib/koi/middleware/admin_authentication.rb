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
        Koi::Current.admin_user = if bearer_token(request).present?
                                    bearer_admin_user(request)
                                  else
                                    session_admin_user(session)
                                  end

        # Remove from session if not found
        session.delete(:admin_user_id) if session.has_key?(:admin_user_id) && !authenticated?

        if requires_authentication?(request) && !authenticated?
          unauthorized_response(request)
        else
          @app.call(env)
        end
      ensure
        Koi::Current.admin_user = nil
      end

      private

      def requires_authentication?(request)
        !request.path.starts_with?("/admin/session") && !device_flow_request?(request)
      end

      def authenticated?
        Koi::Current.admin_user.present?
      end

      def bearer_admin_user(request)
        token = bearer_token(request)
        return if token.blank?

        request.session_options[:skip] = true

        Admin::User.find_by_token_for(:api_access, token)
      end

      def session_admin_user(session)
        Admin::User.find_by(id: session[:admin_user_id])
      end

      def bearer_token(request)
        return nil if request.authorization.blank?

        request.authorization.match(/^Bearer (?<token>.+)$/)&.named_captures&.fetch("token", nil)
      end

      def unauthorized_response(request)
        if bearer_token(request).present?
          # If the user provided a token, it was not valid, and the request requires authentication
          [401, {}, []]
        else
          if request.get?
            # Set the redirection path for returning the user to their requested path after login
            request.flash[:redirect] = request.fullpath
            request.commit_flash
          end

          [303, { "Location" => "/admin/session/new" }, []]
        end
      end

      def device_flow_request?(request)
        request.post? && %w[/admin/device_authorizations /admin/device_tokens].include?(request.path)
      end
    end
  end
end
