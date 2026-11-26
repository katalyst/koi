# frozen_string_literal: true

module Admin
  module AdminUsers
    # Generates a login link that signs in as the given admin user.
    class TokensController < ApplicationController
      before_action :requires_session_authentication!
      before_action :set_admin_user

      attr_reader :admin_user

      def create
        render locals: { token: admin_user.generate_token_for(:password_reset) }
      end

      private

      def set_admin_user
        @admin_user = Admin::User.find(params.expect(:admin_user_id))
      end
    end
  end
end
