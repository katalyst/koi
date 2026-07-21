# frozen_string_literal: true

module Admin
  class AdminRolesController < ApplicationController
    before_action :requires_session_authentication!
    before_action :set_role, only: %i[show]
    before_action :materialize_roles, only: %i[index]

    attr_reader :role

    def index
      collection = Collection.new.with_params(params).apply(Admin::Role.strict_loading)

      render locals: { collection: }
    end

    def show
      render locals: { role:, members:, providers: }
    end

    private

    def set_role
      @role = Admin::Role.find(params.expect(:id))
    end

    def members
      role.members
    end

    def providers
      names = members.map(&:provider)

      Koi::Identity.providers.select { |provider| names.include?(provider.name) }
    end

    def materialize_roles
      Koi::Identity.role_slugs.each do |slug|
        Admin::Role.materialize(slug)
      end
    end

    class Collection < Admin::Collection
      config.sorting = :slug

      attribute :slug, :string
    end
  end
end
