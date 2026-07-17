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
        cookies = request.cookie_jar

        # Always retrieve user to ensure we are not vulnerable to timing attacks
        if (token         = bearer_token(request:)).present?
          Koi::Current.device_authorization = find_device_authentication(token:)

          # disable Rails session for API requests
          request.session_options[:skip]    = true
        elsif (session_id = cookies.signed[:admin_session_id]).present?
          Koi::Current.session = find_admin_session(session_id:)
        end

        # Remove from session if not found
        cookies.delete(:admin_session_id) unless authenticated?

        if requires_authentication?(request) && !authenticated?
          unauthorized_response(request)
        else
          @app.call(env)
        end
      ensure
        Koi::Current.reset
      end

      private

      def requires_authentication?(request)
        !request.path.starts_with?("/admin/session") && !device_flow_request?(request:)
      end

      def authenticated?
        Koi::Current.admin_user.present?
      end

      def find_device_authentication(token:)
        Admin::DeviceAuthorization.find_by_token_for(:api_access, token)
      end

      def find_admin_session(session_id:)
        Admin::Session.find_by(id: session_id)
      end

      def unauthorized_response(request)
        if bearer_token(request:).present?
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

      def device_flow_request?(request:)
        request.post? && %w[/admin/device_authorizations /admin/tokens].include?(request.path)
      end

      def bearer_token(request:)
        return nil if request.authorization.blank?

        request.authorization.match(/^Bearer (?<token>.+)$/)&.named_captures&.fetch("token", nil)
      end
    end
  end
end
