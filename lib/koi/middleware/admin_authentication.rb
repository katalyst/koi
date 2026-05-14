# frozen_string_literal: true

module Koi
  module Middleware
    # Authenticates admin requests via bearer token or persisted browser session.
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

      # Handles authentication for admin requests and clears invalid session cookies.
      # @param env [Hash]
      # @return [Array(Integer, Hash, #each)]
      def admin_call(env)
        request           = ActionDispatch::Request.new(env)
        cookie_session_id = request.cookie_jar.signed[Koi::Controller::RecordsAuthentication::ADMIN_SESSION_COOKIE]

        # Always retrieve user to ensure we are not vulnerable to timing attacks
        auth_strategy = authenticate_request(request, cookie_session_id)

        response = if requires_authentication?(request) && !authenticated?
                     unauthorized_response(request)
                   else
                     @app.call(env)
                   end

        if invalid_admin_cookie?(cookie_session_id, auth_strategy)
          clear_admin_cookie(request, response)
        else
          response
        end
      ensure
        Koi::Current.admin_session = nil
        Koi::Current.admin_user    = nil
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

      # Authenticates the request and records which auth strategy was used.
      # @param request [ActionDispatch::Request]
      # @param cookie_session_id [String, nil]
      # @return [Symbol] `:bearer` when the Authorization header was used,
      #   `:cookie` when the signed admin session cookie was used.
      def authenticate_request(request, cookie_session_id)
        if bearer_token(request).present?
          Koi::Current.admin_user = bearer_admin_user(request)
          :bearer
        else
          Koi::Current.admin_session = cookie_admin_session(cookie_session_id)
          :cookie
        end
      end

      # Determines whether an admin session cookie should be cleared.
      # @param cookie_session_id [String, nil]
      # @param auth_strategy [Symbol]
      # @return [Boolean]
      def invalid_admin_cookie?(cookie_session_id, auth_strategy)
        auth_strategy == :cookie && cookie_session_id.present? && Koi::Current.admin_session.blank?
      end

      # Writes a deleted admin session cookie to the Rack response.
      # @param request [ActionDispatch::Request]
      # @param response [Array(Integer, Hash, #each)]
      # @return [Array(Integer, Hash, #each)]
      def clear_admin_cookie(request, response)
        request.cookie_jar.delete(Koi::Controller::RecordsAuthentication::ADMIN_SESSION_COOKIE)
        rack_response = Rack::Response.new(response[2], response[0], response[1])
        request.cookie_jar.write(rack_response)
        rack_response.finish
      end

      # Loads the persisted admin session referenced by the signed cookie.
      # @param session_id [String, nil]
      # @return [Admin::Session, nil]
      def cookie_admin_session(session_id)
        return if session_id.blank?

        admin_session = Admin::Session.includes(:admin).find_by(id: session_id)
        return if admin_session&.admin.blank?

        admin_session
      end

      # Extracts a bearer token from the Authorization header.
      # @param request [ActionDispatch::Request]
      # @return [String, nil]
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
