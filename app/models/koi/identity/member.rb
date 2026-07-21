# frozen_string_literal: true

module Koi
  module Identity
    # A named trust rule from config: pairs a provider and an exact subject
    # with the scope a verified assertion may act as.
    class Member
      include ActiveModel::Model
      include ActiveModel::Attributes

      SCOPES = %r{\Aadmin/user\z|\Aadmin/role/(?<slug>[a-z0-9_]+)\z}

      attribute :name, :string
      attribute :provider, :string
      attribute :scope, :string
      attribute :subject, :string

      # Provider names declared in config, for cross-checking references.
      attr_accessor :provider_names

      validates :provider, :scope, :subject, presence: true
      validates :provider, inclusion: { in: ->(member) { member.provider_names || [] }, allow_blank: true }
      validates :scope, format: { with: SCOPES, allow_blank: true }

      def role_slug
        scope&.[](SCOPES, :slug)
      end
    end
  end
end
