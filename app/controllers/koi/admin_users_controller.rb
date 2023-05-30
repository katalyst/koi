# frozen_string_literal: true

module Koi
  class AdminUsersController < ApplicationController
    before_action :set_admin, only: %i[show edit update destroy]

    def index
      @admins ||= AdminUser.strict_loading.all

      @admins = @admins.admin_search(params[:search]) if params[:search]

      sort, @admins = table_sort(@admins)
      pagy, @admins = pagy(@admins)

      @admins = @admins.alphabetical

      render :index, locals: { admins: @admins, sort:, pagy: }
    end

    def show
      render :show, locals: { admin: @admin }
    end

    def new
      @admin = AdminUser.new

      render :new, locals: { admin: @admin }
    end

    def edit
      render :edit, locals: { admin: @admin }
    end

    def create
      @admin = AdminUser.new(admin_user_params)

      if @admin.save
        redirect_to admin_user_path(@admin)
      else
        render :new, locals: { admin: @admin }, status: :unprocessable_entity
      end
    end

    def update
      if @admin.update(admin_user_params)
        redirect_to action: :show
      else
        render :edit, locals: { admin: @admin }, status: :unprocessable_entity
      end
    end

    def destroy
      @admin.destroy

      redirect_to admin_users_path
    end

    private

    def set_admin
      @admin = AdminUser.find(params[:id])
    end

    def admin_user_params
      params.require(:admin).permit(:first_name, :last_name, :email, :role, :password)
    end
  end
end
