# frozen_string_literal: true

require "jwt"
require "net/http"

module Koi
  module Identity
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
    # principal, typed by the issuer.
    def principal_for(provider, assertion)
      Koi.config.identity.members.values
        .select { |config| config[:provider].to_s == provider.name }
        .filter_map do |config|
          Principal.from_assertion(config:, provider:, assertion:)
        end.first
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

    module_function :authorize_bearer_token!, :provider_for, :principal_for, :providers
  end
end
