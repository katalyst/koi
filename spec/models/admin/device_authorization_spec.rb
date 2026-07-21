# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::DeviceAuthorization do
  include ActiveSupport::Testing::TimeHelpers

  subject(:device_authorization) { build(:admin_device_authorization) }

  it { is_expected.to belong_to(:admin_user).class_name("Admin::User").optional }
  it { is_expected.to belong_to(:admin_role).class_name("Admin::Role").optional }

  it "forbids a grant holding both an admin and a role" do
    grant = create(:admin_device_authorization)

    expect { grant.update!(status: :consumed, admin_user: create(:admin), admin_role: create(:admin_role)) }
      .to raise_error(ActiveRecord::StatementInvalid)
  end

  it { is_expected.to validate_presence_of(:device_code_digest) }
  it { is_expected.to validate_presence_of(:user_code) }
  it { is_expected.to validate_presence_of(:status) }
  it { is_expected.to validate_presence_of(:request_expires_at) }

  it { is_expected.to validate_uniqueness_of(:device_code_digest) }
  it { is_expected.to validate_uniqueness_of(:user_code) }

  it "defines status enum" do
    expect(device_authorization).to define_enum_for(:status).with_values(
      pending:  "pending",
      approved: "approved",
      denied:   "denied",
      consumed: "consumed",
    ).backed_by_column_of_type(:string)
  end

  describe "#expired?" do
    it "returns false when the request has not expired" do
      device_authorization = build(:admin_device_authorization, request_expires_at: 10.minutes.from_now)

      expect(device_authorization).not_to be_expired
    end

    it "returns true when the request has expired" do
      device_authorization = build(:admin_device_authorization, request_expires_at: 1.second.ago)

      expect(device_authorization).to be_expired
    end
  end

  describe "#issuable?" do
    it "returns true for an approved unexpired authorization" do
      device_authorization = build(:admin_device_authorization, :approved, request_expires_at: 10.minutes.from_now)

      expect(device_authorization).to be_issuable
    end

    it "returns false for a pending authorization" do
      device_authorization = build(:admin_device_authorization, request_expires_at: 10.minutes.from_now)

      expect(device_authorization).not_to be_issuable
    end

    it "returns false for an expired approved authorization" do
      device_authorization = build(:admin_device_authorization, :approved, request_expires_at: 1.second.ago)

      expect(device_authorization).not_to be_issuable
    end

    it "returns false for denied authorizations" do
      device_authorization = build(:admin_device_authorization, :denied, request_expires_at: 10.minutes.from_now)

      expect(device_authorization).not_to be_issuable
    end

    it "returns false for consumed authorizations" do
      device_authorization = build(:admin_device_authorization, :consumed, request_expires_at: 10.minutes.from_now)

      expect(device_authorization).not_to be_issuable
    end
  end

  describe ".consume_request!" do
    let(:device_code) { "device-code-123" }

    it "raises invalid_grant for an unknown device code" do
      expect do
        described_class.consume_request!(device_code:)
      end.to raise_error(described_class::TokenError, "invalid_grant")
    end

    it "raises authorization_pending for pending authorizations" do
      create(:admin_device_authorization, device_code_digest: described_class.digest(device_code))

      expect do
        described_class.consume_request!(device_code:)
      end.to raise_error(described_class::TokenError, "authorization_pending")
    end

    it "raises access_denied for denied authorizations" do
      create(:admin_device_authorization, :denied, device_code_digest: described_class.digest(device_code))

      expect do
        described_class.consume_request!(device_code:)
      end.to raise_error(described_class::TokenError, "access_denied")
    end

    it "raises invalid_grant for expired authorizations" do
      create(
        :admin_device_authorization,
        :approved,
        device_code_digest: described_class.digest(device_code),
        request_expires_at: 1.second.ago,
      )

      expect do
        described_class.consume_request!(device_code:)
      end.to raise_error(described_class::TokenError, "invalid_grant")
    end

    it "returns the token payload for approved authorizations" do
      admin_user = create(:admin)
      create(
        :admin_device_authorization,
        :approved,
        admin_user:,
        device_code_digest: described_class.digest(device_code),
      )

      payload = described_class.consume_request!(device_code:)

      expect(payload).to include(
        access_token: a_kind_of(String),
        token_type:   "Bearer",
        expires_in:   3600,
      )
    end

    it "returns a token that authenticates the approving admin" do
      device_authorization = create(:admin_device_authorization, :approved,
                                    device_code_digest: described_class.digest(device_code))

      payload = described_class.consume_request!(device_code:)

      expect(described_class.find_by_token_for(:api_access, payload.fetch(:access_token)))
        .to eq(device_authorization)
    end

    it "consumes approved authorizations when issuing a token" do
      device_authorization = create(
        :admin_device_authorization,
        :approved,
        device_code_digest: described_class.digest(device_code),
      )

      described_class.consume_request!(device_code:)

      expect(device_authorization.reload).to have_attributes(
        status:           "consumed",
        consumed_at:      be_present,
        token_expires_at: be_present,
      )
    end
  end

  describe ".issue_token!" do
    let(:admin) { create(:admin) }

    def principal(scope: "admin/user", email: admin.email, **)
      Koi::Identity::Principal.new(scope:, email:, **)
    end

    it "returns the token payload" do
      payload = described_class.issue_token!(principal:)

      expect(payload).to include(
        access_token: a_kind_of(String),
        token_type:   "Bearer",
        expires_in:   3600,
      )
    end

    it "records a consumed grant without a device-code request" do
      described_class.issue_token!(principal:, requested_ip: "127.0.0.1", user_agent: "RSpec")

      expect(described_class.last).to have_attributes(
        admin_user:         admin,
        status:             "consumed",
        consumed_at:        be_present,
        token_expires_at:   be_present,
        device_code_digest: nil,
        user_code:          nil,
        request_expires_at: nil,
        requested_ip:       "127.0.0.1",
        user_agent:         "RSpec",
      )
    end

    it "returns a token that authenticates the grant" do
      payload = described_class.issue_token!(principal:)

      expect(described_class.find_by_token_for(:api_access, payload.fetch(:access_token)))
        .to eq(described_class.last)
    end

    it "raises for a user principal that matches no admin" do
      expect do
        described_class.issue_token!(principal: principal(email: "unknown@example.com"))
      end.to raise_error(JWT::VerificationError, /unknown user/)
    end

    it "binds the grant to the materialized role for a role-scoped principal" do
      principal = principal(scope: "admin/role/event_editor")

      described_class.issue_token!(principal:)

      expect(described_class.last).to have_attributes(
        admin_role: Admin::Role.find_by!(slug: "event_editor"),
        admin_user: nil,
      )
    end

    it "raises for an unknown scope" do
      principal = principal(scope: "admin/other")

      expect do
        described_class.issue_token!(principal:)
      end.to raise_error(ArgumentError, /unknown scope/)
    end

    it "snapshots the principal onto the grant" do
      described_class.issue_token!(principal: principal(provider: "komet", subject: "komet-production"))

      expect(described_class.last.principal)
        .to have_attributes(provider: "komet", subject: "komet-production", scope: "admin/user")
    end
  end

  describe "API access tokens" do
    subject(:device_authorization) { create(:admin_device_authorization, :approved) }

    it "is valid immediately after issuance" do
      token = device_authorization.generate_token_for(:api_access)

      expect(described_class.find_by_token_for(:api_access, token)).to eq(device_authorization)
    end

    it "is rejected after an hour" do
      token = device_authorization.generate_token_for(:api_access)

      travel(1.hour + 1.second) do
        expect(described_class.find_by_token_for(:api_access, token)).to be_nil
      end
    end

    it "is invalidated when last_sign_in_at changes" do
      token = device_authorization.generate_token_for(:api_access)

      device_authorization.admin_user.update!(last_sign_in_at: 1.second.from_now)

      expect(described_class.find_by_token_for(:api_access, token)).to be_nil
    end
  end
end
