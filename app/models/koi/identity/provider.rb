# frozen_string_literal: true

module Koi
  module Identity
    class Provider
      include ActiveModel::Model
      include ActiveModel::Attributes

      # Upper bound on how long a key removed from the issuer's JWKS remains
      # trusted. Newly rotated-in keys are picked up immediately, as an
      # unknown kid invalidates the cache.
      KEY_SET_TTL = 1.hour

      # A cached key set younger than this cannot be invalidated, so a stream
      # of unknown-kid assertions cannot force a discovery refetch per
      # request. A rotated-in key may take this long to be honoured.
      INVALIDATION_GRACE = 5.minutes

      attribute :name, :string
      attribute :issuer, :string
      attribute :keys, :string
      attribute :audience, :string

      # Acceptable signature algorithms: asymmetric families only, so a
      # provider's public key can never be replayed as an HMAC secret and
      # unsigned (none) tokens are rejected before key lookup.
      attribute :algorithms, default: -> { %w[ES256 ES384 ES512 RS256 RS384 RS512 PS256 PS384 PS512].freeze }

      # Allowed clock drift for verification
      attribute :leeway, default: -> { 15.seconds }

      # Upper bound on assertion lifetime. Exchange is immediate, so a
      # distant expiry indicates an integration minting long-lived
      # credentials; require assertions to be short-lived instead
      # (RFC 7523 §3).
      attribute :max_expiry, default: -> { 1.hour }

      validates :keys, inclusion: { in: %w[env discover] }
      validate :pinned_keys_parse, if: -> { keys == "env" }

      # This provider's JWKS: pinned from ENV or fetched via OIDC discovery
      # and cached. Passed to JWT.decode as its jwks loader, which retries
      # with invalidate: true when a presented kid is missing from the set.
      def key_set(options = {})
        invalidate_key_set if options[:invalidate]

        JWT::JWK::Set.new(jwks)
      end

      # Trusted-keys summary for the roles page: RFC 7638 thumbprints, plus
      # when a discovered set was cached. Viewing may prime the discovery
      # cache — the same fail-closed path verification uses — and an
      # unreachable issuer reports itself rather than raising.
      def key_status
        case keys
        when "env"
          { fingerprints: fingerprints(jwks) }
        when "discover"
          cached = cached_discovery

          { fingerprints: fingerprints(cached.fetch("jwks")),
            fetched_at:   Time.zone.at(cached.fetch("fetched_at")) }
        end
      rescue JWT::JWKError => e
        { error: e.message }
      end

      # Identity attributes are issuer-specific: AWS issuers carry
      # admin-controlled principal tags; other issuers assert no identity
      # beyond their subject. Keyed by the verified issuer — never by claim
      # shape, which any trusted signer could imitate.
      def identity_attributes(claims)
        case URI.parse(issuer.to_s).host
        when /\.sts\.global\.api\.aws\z/
          claims.dig("https://sts.amazonaws.com/", "principal_tags")&.slice("name", "email") || {}
        else
          {}
        end
      end

      # Atomically claims an assertion's jti for its replayable lifetime:
      # the first presentation writes the key, a replay finds it taken and
      # is rejected. jti uniqueness is only promised within an issuer
      # (RFC 7519), so entries are scoped per provider. Requires a cache
      # store shared by all app processes.
      def consume_jti(jti, claims)
        jti.present? &&
          Rails.cache.write("koi/identity/jti/#{name}/#{jti}", true,
                            unless_exist: true,
                            expires_in:   Time.zone.at(claims["exp"].to_i) + leeway - Time.current)
      end

      private

      def pinned_keys_parse
        JWT::JWK::Set.new(JSON.parse(ENV.fetch(env_name)))
      rescue KeyError, JSON::ParserError, JWT::JWKError => e
        errors.add(:keys, "ENV #{env_name} is unavailable or invalid (#{e.message})")
      end

      def fingerprints(jwks)
        JWT::JWK::Set.new(jwks).map { |jwk| JWT::JWK::Thumbprint.new(jwk).generate }
      end

      def env_name
        "KOI_API_JWKS_#{name.upcase}"
      end

      def jwks
        case keys
        when "env"
          JSON.parse(ENV.fetch(env_name))
        when "discover"
          cached_discovery.fetch("jwks")
        end
      end

      def cached_discovery
        Rails.cache.fetch(key_set_cache_key, expires_in: KEY_SET_TTL) do
          { "fetched_at" => Time.current.to_i, "jwks" => discover_jwks }
        end
      end

      def discover_jwks
        discovery = JSON.parse(Net::HTTP.get(URI.parse("#{issuer}/.well-known/openid-configuration")))

        # Mix-up defence: only the configured issuer's own keys are trusted.
        unless discovery["issuer"] == issuer
          raise JWT::JWKError, "#{name} discovery names issuer #{discovery['issuer'].inspect}, expected #{issuer}"
        end

        JSON.parse(Net::HTTP.get(URI.parse(discovery.fetch("jwks_uri"))))
      rescue JWT::JWKError
        raise
      rescue StandardError => e
        raise JWT::JWKError, "key discovery for #{name} failed: #{e.message} (#{e.class})"
      end

      def invalidate_key_set
        cached = Rails.cache.read(key_set_cache_key)
        return if cached && cached.fetch("fetched_at") > INVALIDATION_GRACE.ago.to_i

        Rails.cache.delete(key_set_cache_key)
      end

      def key_set_cache_key
        "koi/identity/jwks/#{name}"
      end
    end
  end
end
