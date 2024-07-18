# frozen_string_literal: true

module Admin
  class AdminUsersController < ApplicationController
    before_action :set_admin, only: %i[show edit update destroy]

    attr_reader :admin

    def index
      collection = Collection.new.with_params(params).apply(Admin::User.strict_loading)

      render locals: { collection: }
    end

    def archived
      collection = Collection.new.with_params(params).apply(Admin::User.archived.strict_loading)

      render locals: { collection: }
    end

    def show
      render :show, locals: { admin: }
    end

    def new
      @admin = Admin::User.new

      render :new, locals: { admin: }
    end

    def edit
      render :edit, locals: { admin: }
    end

    def create
      admin = Admin::User.new(admin_user_params)

      if admin.save
        redirect_to admin_admin_user_path(admin)
      else
        render :new, locals: { admin: }, status: :unprocessable_content
      end
    end

    def update
      if admin.update(admin_user_params)
        redirect_to action: :show
      else
        render :edit, locals: { admin: }, status: :unprocessable_content
      end
    end

    def archive
      Admin::User.where(id: params[:id]).where.not(id: current_admin.id).each(&:archive!)

      redirect_back(fallback_location: admin_admin_users_path, status: :see_other)
    end

    def restore
      Admin::User.archived.where(id: params[:id]).each(&:restore!)

      redirect_back(fallback_location: admin_admin_users_path, status: :see_other)
    end

    def destroy
      admin.destroy

      redirect_to admin_admin_users_path
    end

    private

    def set_admin
      @admin = Admin::User.with_archived.find(params[:id])
    end

    def admin_user_params
      params.require(:admin).permit(:name, :email, :password, :archived)
    end

    class Collection < Admin::Collection
      config.sorting  = :name
      config.paginate = true

      attribute :name, :string
      attribute :email, :string
      attribute :last_sign_in_at, :date
      attribute :sign_in_count, :integer
    end
  end
end
