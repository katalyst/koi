# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::User do
  include ActiveSupport::Testing::TimeHelpers

  subject!(:admin) { create(:admin) }

  let!(:archived) { create(:admin, archived: true) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:email) }

  it { is_expected.to have_many(:credentials).class_name("Admin::Credential").dependent(:destroy) }
  it { is_expected.to have_many(:device_authorizations).class_name("Admin::DeviceAuthorization").dependent(:destroy) }
  it { is_expected.to have_many(:sessions).class_name("Admin::Session").dependent(:destroy) }

  it { is_expected.to allow_values("a@b.com").for(:email) }
  it { is_expected.not_to allow_values("@b.com", "fail").for(:email) }

  it "normalizes email" do
    admin.email = " ADMIN@EXAMPLE.COM "

    expect(admin.email).to eq("admin@example.com")
  end

  describe "#admin_search" do
    it { expect(described_class.admin_search(admin.name)).to include(admin) }
    it { expect(described_class.admin_search(admin.email)).to include(admin) }
  end

  describe ".all" do
    it { expect(described_class.all).to contain_exactly(admin) }
  end

  describe ".not_archived" do
    it { expect(described_class.not_archived).to contain_exactly(admin) }
  end

  describe ".with_archived" do
    it { expect(described_class.with_archived).to contain_exactly(admin, archived) }
  end

  describe ".archived" do
    it { expect(described_class.archived).to contain_exactly(archived) }
  end

  describe ".has_password_login" do
    let!(:no_password) { create(:admin, password_digest: "") }
    let!(:password_only) { create(:admin, otp_secret: nil) }
    let!(:mfa) { admin }

    it { expect(described_class.has_password_login(:password_only)).to contain_exactly(password_only) }
    it { expect(described_class.has_password_login(:mfa)).to contain_exactly(mfa) }
    it { expect(described_class.has_password_login(:none)).to contain_exactly(no_password) }
  end

  describe "#password_login" do
    it "returns :none when password_digest is blank" do
      expect(create(:admin, password_digest: "").password_login).to eq(:none)
    end

    it "returns :password_only when password_digest is set without otp_secret" do
      expect(create(:admin, otp_secret: nil).password_login).to eq(:password_only)
    end

    it "returns :mfa when password_digest and otp_secret are set" do
      expect(create(:admin).password_login).to eq(:mfa)
    end
  end

  describe "#last_active_at" do
    it "returns the most recent active session" do
      travel_to(2.days.ago.at_noon) { admin.sessions.create!(ip_address: "1.2.3.4", user_agent: "Mozilla") }
      expect(admin.last_active_at).to eq(2.days.ago.at_noon)
    end

    it "returns the most recent log out if no active sessions" do
      travel_to(2.days.ago.at_noon) { admin.sessions.create!(ip_address: "1.2.3.4", user_agent: "Mozilla") }
      travel_to(1.day.ago.at_noon) { admin.sessions.destroy_all }
      expect(admin.last_active_at).to eq(1.day.ago.at_noon)
    end
  end

  describe "#previous_active_at" do
    it "excludes current session" do
      Koi::Current.session = admin.sessions.create!(ip_address: "1.2.3.4", user_agent: "Mozilla")
      expect(admin.previous_active_at).to be_nil
    end
  end
end
