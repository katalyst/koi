# frozen_string_literal: true

module Admin
  class OtpsController < ApplicationController
    alias_method :admin_user, :current_admin

    def new
      admin_user.otp_secret = ROTP::Base32.random

      render :new, locals: { admin_user: }
    end

    def create
      admin_user.otp_secret = otp_params[:otp_secret]

      if admin_user.otp.verify(otp_params[:token])
        admin_user.save!

        redirect_to admin_profile_path, status: :see_other
      else
        admin_user.errors.add(:token, :invalid)

        respond_to do |format|
          format.html { redirect_to admin_profile_path, status: :see_other }
          format.turbo_stream { render locals: { admin_user: }, status: :unprocessable_content }
        end
      end
    end

    def destroy
      admin_user.update!(otp_secret: nil)

      redirect_to admin_profile_path, status: :see_other
    end

    private

    def otp_params
      params.expect(admin_user: %i[otp_secret token])
    end
  end
end
