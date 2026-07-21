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

    # Generates a reader for the assertion claims based on configuration.
    def principal_for(provider, assertion)
      principal_type = case URI.parse(provider.issuer).host
                       when /\.sts\.global\.api\.aws\z/
                         Principal::Aws
                       else
                         Principal
                       end

      Koi.config.identity.members
        .select { |_, config| config[:provider].to_s == provider.name }
        .filter_map do |name, config|
          principal_type.new(assertion:, name:, **config) if config[:subject] == assertion.subject
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
