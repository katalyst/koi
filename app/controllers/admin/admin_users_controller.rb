# frozen_string_literal: true

module Admin
  class AdminUsersController < ApplicationController
    before_action :set_admin_user, only: %i[show edit update destroy]

    attr_reader :admin_user

    def index
      collection = Collection.new.with_params(params).apply(Admin::User.strict_loading)

      render locals: { collection: }
    end

    def archived
      collection = Collection.new.with_params(params).apply(Admin::User.archived.strict_loading)

      render locals: { collection: }
    end

    def show
      render locals: { admin_user: }
    end

    def new
      @admin_user = Admin::User.new

      render locals: { admin_user: }
    end

    def edit
      render :edit, locals: { admin_user: }
    end

    def create
      admin_user = Admin::User.new(admin_user_params)

      if admin_user.save
        redirect_to admin_admin_user_path(admin_user)
      else
        render :new, locals: { admin_user: }, status: :unprocessable_content
      end
    end

    def update
      if admin_user.update(admin_user_params)
        redirect_to action: :show
      else
        render :edit, locals: { admin_user: }, status: :unprocessable_content
      end
    end

    def archive
      Admin::User.where(id: params[:id]).where.not(id: current_admin.id).each(&:archive!)

      redirect_back_or_to(admin_admin_users_path, status: :see_other)
    end

    def restore
      Admin::User.archived.where(id: params[:id]).each(&:restore!)

      redirect_back_or_to(admin_admin_users_path, status: :see_other)
    end

    def destroy
      return redirect_back_or_to(admin_admin_users_path, status: :see_other) if admin_user == current_admin

      if admin_user.archived?
        admin_user.destroy!

        redirect_to admin_admin_users_path
      else
        admin_user.archive!

        redirect_back_or_to(admin_admin_user_path(admin_user), status: :see_other)
      end
    end

    private

    def set_admin_user
      @admin_user = Admin::User.with_archived.find(params[:id])
    end

    def admin_user_params
      params.expect(admin_user: %i[name email password archived])
    end

    class Collection < Admin::Collection
      config.sorting  = :name
      config.paginate = true

      attribute :name, :string
      attribute :email, :string
      attribute :last_sign_in_at, :date
      attribute :sign_in_count, :integer
      attribute :password_login, :enum, scope: :has_password_login, multiple: false
      attribute :passkey, :boolean, scope: :has_passkey
    end
  end
end
