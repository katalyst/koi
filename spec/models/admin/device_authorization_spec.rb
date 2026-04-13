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
end
