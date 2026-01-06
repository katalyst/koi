# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::User do
  subject!(:admin) { create(:admin) }

  let!(:archived) { create(:admin, archived: true) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:email) }

  it { is_expected.to have_many(:credentials).class_name("Admin::Credential").dependent(:destroy) }

  it { is_expected.to allow_values("a@b.com").for(:email) }
  it { is_expected.not_to allow_values("@b.com", "fail").for(:email) }

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
end
