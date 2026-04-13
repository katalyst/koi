# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::DeviceAuthorization do
  subject(:device_authorization) { build(:admin_device_authorization) }

  it { is_expected.to belong_to(:admin_user).class_name("Admin::User").optional }

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

  describe ".issue_access_token!" do
    let(:device_code) { "device-code-123" }

    it "raises invalid_grant for an unknown device code" do
      expect do
        described_class.issue_access_token!(device_code:)
      end.to raise_error(described_class::TokenError, "invalid_grant")
    end

    it "raises authorization_pending for pending authorizations" do
      create(:admin_device_authorization, device_code_digest: described_class.digest(device_code))

      expect do
        described_class.issue_access_token!(device_code:)
      end.to raise_error(described_class::TokenError, "authorization_pending")
    end

    it "raises access_denied for denied authorizations" do
      create(:admin_device_authorization, :denied, device_code_digest: described_class.digest(device_code))

      expect do
        described_class.issue_access_token!(device_code:)
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
        described_class.issue_access_token!(device_code:)
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

      payload = described_class.issue_access_token!(device_code:)

      expect(payload).to include(
        access_token: a_kind_of(String),
        token_type:   "Bearer",
        expires_in:   43_200,
      )
    end

    it "returns a token that authenticates the approving admin" do
      admin_user = create(:admin)
      create(
        :admin_device_authorization,
        :approved,
        admin_user:,
        device_code_digest: described_class.digest(device_code),
      )

      payload = described_class.issue_access_token!(device_code:)

      expect(Admin::User.find_by_token_for(:api_access, payload.fetch(:access_token))).to eq(admin_user)
    end

    it "consumes approved authorizations when issuing a token" do
      device_authorization = create(
        :admin_device_authorization,
        :approved,
        admin_user:         create(:admin),
        device_code_digest: described_class.digest(device_code),
      )

      described_class.issue_access_token!(device_code:)

      expect(device_authorization.reload).to have_attributes(
        status:           "consumed",
        consumed_at:      be_present,
        token_expires_at: be_present,
      )
    end
  end
end
