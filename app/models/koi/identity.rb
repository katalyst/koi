# frozen_string_literal: true

require "jwt"
require "net/http"

module Koi
  module Identity
    module_function

    def authorize_bearer_token!(token, audience:)
      assertion = Assertion.new(token)
      provider  = provider_for(assertion)

      provider.audience ||= audience
      raise JWT::InvalidAudError, "no expected audience" if provider.audience.blank?

      assertion.verify!(provider)
    rescue JWT::DecodeError => e
      Rails.logger.warn("#{e.class}: Koi::Identity rejected assertion #{assertion.inspect}: #{e.message}")
      raise
    end

    def provider_for(assertion)
      providers.find { |provider| provider.issuer == assertion.issuer } ||
        raise(JWT::InvalidIssuerError, "unknown issuer #{assertion.issuer}")
    end

    # Resolves the member matching the verified (provider, subject) into a
    # principal, carrying whatever identity attributes the issuer publishes.
    def principal_for(provider, assertion)
      member = members.find { |m| m.provider == provider.name && m.subject == assertion.subject }

      return if member.nil?

      Principal.new(provider: provider.name,
                    scope:    member.scope,
                    subject:  assertion.subject,
                    **provider.identity_attributes(assertion.claims))
    end

    def providers
      Koi.config.identity.providers.map do |name, config|
        provider = Provider.new(name:, **config)
        unless provider.valid?
          raise ArgumentError, "Invalid identity provider #{name}: #{provider.errors.full_messages.to_sentence}"
        end

        provider
      end
    end

    def members
      provider_names = Koi.config.identity.providers.keys.map(&:to_s)

      Koi.config.identity.members.map do |name, config|
        member = Member.new(name:, provider_names:, **config)
        unless member.valid?
          raise ArgumentError, "Invalid identity member #{name}: #{member.errors.full_messages.to_sentence}"
        end

        member
      end
    end

    # Role slugs granted by config; roles outside this set are not assumable.
    def role_slugs
      members.filter_map(&:role_slug)
    end
  end
end
