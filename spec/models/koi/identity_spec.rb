# frozen_string_literal: true

require "rails_helper"
require "jwt"

RSpec.describe Koi::Identity do
  include ActiveSupport::Testing::TimeHelpers

  describe ".authorize_bearer_token!" do
    let(:issuer) { "https://00000000-0000-0000-0000-000000000000.tokens.sts.global.api.aws" }
    let(:audience) { "https://localhost/admin" }
    let(:email) { "developer@katalyst.com.au" }

    let(:role_arn) do
      "arn:aws:iam::123456789012:role/aws-reserved/sso.amazonaws.com" \
        "/ap-southeast-2/AWSReservedSSO_Engineer_0123456789abcdef"
    end

    let(:signing_key) { OpenSSL::PKey::EC.generate("secp384r1") }
    let(:jwk) { JWT::JWK.new(signing_key) }

    let(:claims) do
      now = Time.zone.now.to_i
      {
        iss: issuer,
        sub: role_arn,
        aud: audience,
        iat: now,
        exp: now + 300,
        jti: SecureRandom.uuid,
        "https://sts.amazonaws.com/" => {
          "principal_tags" => { "email" => email },
        },
      }
    end
    let(:assertion) { JWT.encode(claims, signing_key, "ES384", { kid: jwk.kid }) }

    def authorize(assertion = self.assertion, audience: self.audience)
      described_class.authorize_bearer_token!(assertion, audience:)
    end

    # The replay guard needs a real cache store; the test environment's
    # default is :null_store, which never holds a jti.
    def with_memory_cache
      original    = Rails.cache
      Rails.cache = ActiveSupport::Cache::MemoryStore.new
      yield
    ensure
      Rails.cache = original
    end

    before do
      Koi.config.identity = {
        providers: {
          katalyst_aws: {
            issuer:,
            keys:     "discover",
            audience:,
          },
        },
        members:   {
          engineers: { provider: :katalyst_aws, scope: "admin/user", subject: role_arn },
        },
      }

      stub_request(:get, "#{issuer}/.well-known/openid-configuration")
        .to_return(headers: { "Content-Type" => "application/json" },
                   body:    { issuer:, jwks_uri: "#{issuer}/keys" }.to_json)
      stub_request(:get, "#{issuer}/keys")
        .to_return(headers: { "Content-Type" => "application/json" },
                   body:    { keys: [jwk.export] }.to_json)
    end

    after { Koi.config.instance_variable_set(:@identity, nil) }

    it "returns a validated assertion carrying the identity claim" do
      expect(authorize.principal).to have_attributes(email:)
    end

    it "verifies assertions signed with either key during rotation overlap" do
      rotated_key = OpenSSL::PKey::EC.generate("secp384r1")
      rotated_jwk = JWT::JWK.new(rotated_key)
      stub_request(:get, "#{issuer}/keys")
        .to_return(headers: { "Content-Type" => "application/json" },
                   body:    { keys: [jwk.export, rotated_jwk.export] }.to_json)

      assertion = JWT.encode(claims, rotated_key, "ES384", { kid: rotated_jwk.kid })

      expect(authorize(assertion).principal).to have_attributes(email:)
    end

    it "verifies RS256 assertions (the algorithm AWS issuers sign with)" do
      rsa_key = OpenSSL::PKey::RSA.new(2048)
      rsa_jwk = JWT::JWK.new(rsa_key)
      stub_request(:get, "#{issuer}/keys")
        .to_return(headers: { "Content-Type" => "application/json" },
                   body:    { keys: [rsa_jwk.export] }.to_json)

      assertion = JWT.encode(claims, rsa_key, "RS256", { kid: rsa_jwk.kid })

      expect(authorize(assertion).principal).to have_attributes(email:)
    end

    it "rejects a malformed assertion" do
      expect { authorize("not-a-jwt") }.to raise_error(an_instance_of(JWT::DecodeError))
    end

    it "rejects an assertion signed by an unregistered key" do
      assertion = JWT.encode(claims, OpenSSL::PKey::EC.generate("secp384r1"), "ES384", { kid: jwk.kid })

      expect { authorize(assertion) }.to raise_error(JWT::VerificationError)
    end

    it "rejects an unsigned (alg: none) assertion" do
      expect { authorize(JWT.encode(claims, nil, "none")) }
        .to raise_error(JWT::IncorrectAlgorithm)
    end

    it "rejects an HMAC assertion using the public key as its secret" do
      assertion = JWT.encode(claims, signing_key.public_to_pem, "HS384", { kid: jwk.kid })

      expect { authorize(assertion) }.to raise_error(JWT::IncorrectAlgorithm)
    end

    it "rejects an assertion with an unknown kid" do
      assertion = JWT.encode(claims, signing_key, "ES384", { kid: "unknown-kid" })

      expect { authorize(assertion) }.to raise_error(an_instance_of(JWT::DecodeError))
    end

    it "rejects an expired assertion" do
      claims[:iat] = 10.minutes.ago.to_i
      claims[:exp] = 5.minutes.ago.to_i

      expect { authorize }.to raise_error(JWT::ExpiredSignature)
    end

    it "accepts clock skew within tolerance" do
      claims[:iat] = 10.seconds.from_now.to_i

      expect(authorize.principal).to have_attributes(email:)
    end

    it "rejects an audience mismatch" do
      claims[:aud] = "https://elsewhere.example.com/admin"

      expect { authorize }.to raise_error(JWT::InvalidAudError)
    end

    it "uses the caller-supplied audience when the provider does not pin one" do
      Koi.config.identity = { providers: { katalyst_aws: { audience: nil } } }

      expect(authorize.principal).to have_attributes(email:)
    end

    it "rejects verification without an expected audience" do
      Koi.config.identity = { providers: { katalyst_aws: { audience: nil } } }

      expect { authorize(audience: nil) }.to raise_error(JWT::InvalidAudError)
    end

    it "rejects an issuer that matches no provider" do
      claims[:iss] = "https://11111111-1111-1111-1111-111111111111.tokens.sts.global.api.aws"

      expect { authorize }.to raise_error(JWT::InvalidIssuerError)
    end

    it "raises for a provider whose key source is unknown" do
      Koi.config.identity = {
        providers: { partner: { issuer: "https://partner.example.com", keys: "database" } },
      }

      expect { authorize }.to raise_error(ArgumentError, /partner/)
    end

    it "rejects a subject other than the provider's expected subject" do
      claims[:sub] = "arn:aws:iam::123456789012:role/unrelated-task-role"

      expect { authorize }.to raise_error(JWT::InvalidSubError)
    end

    it "rejects a replayed jti the second time it is presented", :aggregate_failures do
      with_memory_cache do
        expect(authorize.principal).to have_attributes(email:)

        expect { authorize }.to raise_error(JWT::InvalidJtiError)
      end
    end

    it "caches the key set across verifications" do
      with_memory_cache do
        authorize

        claims[:jti] = SecureRandom.uuid
        authorize(JWT.encode(claims, signing_key, "ES384", { kid: jwk.kid }))

        expect(WebMock).to have_requested(:get, "#{issuer}/keys").once
      end
    end

    it "refetches the key set after its cache TTL expires", :aggregate_failures do
      with_memory_cache do
        authorize

        travel Koi::Identity::Provider::KEY_SET_TTL + 1.second do
          now   = Time.zone.now.to_i
          fresh = JWT.encode(claims.merge(iat: now, exp: now + 300, jti: SecureRandom.uuid),
                             signing_key, "ES384", { kid: jwk.kid })

          expect(authorize(fresh)).to be_verified
          expect(WebMock).to have_requested(:get, "#{issuer}/keys").twice
        end
      end
    end

    it "fails closed when the issuer is unreachable with a cold cache" do
      stub_request(:get, "#{issuer}/.well-known/openid-configuration").to_timeout

      expect { authorize }.to raise_error(JWT::JWKError)
    end

    it "rejects a discovery response naming a different issuer" do
      stub_request(:get, "#{issuer}/.well-known/openid-configuration")
        .to_return(headers: { "Content-Type" => "application/json" },
                   body:    { issuer: "https://elsewhere.example.com", jwks_uri: "#{issuer}/keys" }.to_json)

      expect { authorize }.to raise_error(JWT::JWKError, /\Akatalyst_aws discovery names issuer/)
    end

    it "does not refetch for repeated unknown kids inside the invalidation grace", :aggregate_failures do
      with_memory_cache do
        authorize

        stranger     = OpenSSL::PKey::EC.generate("secp384r1")
        stranger_jwk = JWT::JWK.new(stranger)
        2.times do
          unknown = JWT.encode(claims.merge(jti: SecureRandom.uuid), stranger, "ES384",
                               { kid: stranger_jwk.kid })

          expect { authorize(unknown) }.to raise_error(JWT::DecodeError)
        end

        expect(WebMock).to have_requested(:get, "#{issuer}/keys").once
      end
    end

    it "verifies pinned-key providers from ENV without HTTP, even with discovery down", :aggregate_failures do
      stub_request(:get, "#{issuer}/.well-known/openid-configuration").to_timeout

      partner_key                 = OpenSSL::PKey::EC.generate("secp384r1")
      partner_jwk                 = JWT::JWK.new(partner_key)
      ENV["KOI_API_JWKS_PARTNER"] = { keys: [partner_jwk.export] }.to_json
      Koi.config.identity         = {
        providers: {
          partner: {
            issuer:   "partner",
            keys:     "env",
            audience:,
          },
        },
        members:   {
          partner: {
            provider: "partner",
            scope:    "admin/user",
            subject:  "partner-production",
          },
        },
      }

      assertion = JWT.encode(claims.merge(iss: "partner", sub: "partner-production"),
                             partner_key, "ES384", { kid: partner_jwk.kid })

      expect(authorize(assertion)).to be_verified
      expect(WebMock).not_to have_requested(:get, /partner/)
    ensure
      ENV.delete("KOI_API_JWKS_PARTNER")
    end

    it "refetches a cached key set for an unknown kid once the invalidation grace passes" do
      with_memory_cache do
        authorize

        rotated_key = OpenSSL::PKey::EC.generate("secp384r1")
        rotated_jwk = JWT::JWK.new(rotated_key)
        stub_request(:get, "#{issuer}/keys")
          .to_return(headers: { "Content-Type" => "application/json" },
                     body:    { keys: [jwk.export, rotated_jwk.export] }.to_json)

        travel Koi::Identity::Provider::INVALIDATION_GRACE + 1.second do
          now       = Time.zone.now.to_i
          assertion = JWT.encode(claims.merge(iat: now, exp: now + 300, jti: SecureRandom.uuid),
                                 rotated_key, "ES384", { kid: rotated_jwk.kid })

          expect(authorize(assertion).principal).to have_attributes(email:)
        end
      end
    end

    it "accepts a distinct jti from the same service", :aggregate_failures do
      with_memory_cache do
        expect(authorize.principal).to have_attributes(email:)

        claims[:jti] = SecureRandom.uuid
        fresh        = JWT.encode(claims, signing_key, "ES384", { kid: jwk.kid })

        expect(authorize(fresh).principal).to have_attributes(email:)
      end
    end
  end
end
