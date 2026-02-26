# frozen_string_literal: true

module Admin
  class ProfilesController < ApplicationController
    include Koi::Controller::HasWebauthn

    alias_method :admin_user, :current_admin

    def show
      render locals: { admin_user: }
    end

    def edit
      render :edit, locals: { admin_user: }
    end

    def update
      if admin_user.update(profile_params)
        redirect_to admin_profile_path, status: :see_other
      else
        render :edit, locals: { admin_user: }, status: :unprocessable_content
      end
    end

    private

    def profile_params
      params.expect(admin_user: %i[name email password])
    end
  end
end
