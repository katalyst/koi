# frozen_string_literal: true

module Admin
  class OtpsController < ApplicationController
    before_action :set_admin_user

    def new
      @admin_user.otp_secret = ROTP::Base32.random

      render :new, locals: { admin: @admin_user }
    end

    def create
      @admin_user.otp_secret = otp_params[:otp_secret]

      if @admin_user.otp.verify(otp_params[:token])
        @admin_user.save

        redirect_to admin_admin_user_path(@admin_user), status: :see_other
      else
        @admin_user.errors.add(:token, :invalid)

        respond_to do |format|
          format.html { redirect_to admin_admin_user_path(@admin_user), status: :see_other }
          format.turbo_stream { render locals: { admin: @admin_user } }
        end
      end
    end

    def destroy
      @admin_user.update!(otp_secret: nil)

      redirect_to admin_admin_user_path(@admin_user), status: :see_other
    end

    private

    def otp_params
      params.expect(admin: %i[otp_secret token])
    end

    def set_admin_user
      @admin_user = Admin::User.find(params[:admin_user_id])

      if current_admin == @admin_user
        request.variant = :self
      else
        head(:forbidden)
      end
    end
  end
end
