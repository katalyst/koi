# frozen_string_literal: true

module Admin
  class AdminUsersController < ApplicationController
    before_action :set_admin, only: %i[show edit update destroy]

    def index
      @admins ||= Admin::User.strict_loading.all

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
      @admin = Admin::User.new

      render :new, locals: { admin: @admin }
    end

    def edit
      render :edit, locals: { admin: @admin }
    end

    def create
      @admin = Admin::User.new(admin_user_params)

      if @admin.save
        redirect_to admin_admin_user_path(@admin)
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

      redirect_to admin_admin_users_path
    end

    private

    def set_admin
      @admin = Admin::User.find(params[:id])
    end

    def admin_user_params
      params.require(:admin).permit(:name, :email, :password)
    end
  end
end
