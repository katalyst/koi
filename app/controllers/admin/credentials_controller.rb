# frozen_string_literal: true

module Admin
  class CredentialsController < ApplicationController
    include Koi::Controller::HasWebauthn

    before_action :set_admin_user, only: %i[new create]
    before_action :set_credential, only: %i[show update destroy]

    before_action :check_authorization!

    attr_reader :admin_user, :credential

    def show
      render locals: { credential: }
    end

    def new
      render locals: { admin_user: }
    end

    def create
      webauthn_register!(credential_params[:response])

      if %r{/credentials/new$}.match?(request.referer)
        redirect_to(admin_root_path, status: :see_other)
      else
        redirect_back_or_to(admin_admin_user_path(admin_user), status: :see_other)
      end
    end

    def update
      if credential.update(credential_params)
        redirect_to(admin_admin_user_path(credential.admin), status: :see_other)
      else
        render :show, locals: { credential: }, status: :unprocessable_content
      end
    end

    def destroy
      credential.destroy!

      redirect_to(admin_admin_user_path(credential.admin), status: :see_other)
    end

    private

    def credential_params
      params.expect(admin_credential: %i[nickname response])
    end

    def set_admin_user
      @admin_user = Admin::User.find(params[:admin_user_id])
    end

    def set_credential
      @credential = Credential.find(params[:id])
      @admin_user = @credential.admin
    end

    def check_authorization!
      head(:forbidden) unless admin_user == current_admin_user
    end
  end
end
