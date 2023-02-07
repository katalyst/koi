# frozen_string_literal: true

require "rails_helper"

RSpec.describe AdminUser, type: :model do
  subject(:admin) { create :admin }

  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:email) }

  it { is_expected.to allow_values("a@b.com").for(:email) }
  it { is_expected.not_to allow_values("@b.com", "fail").for(:email) }

  it { is_expected.to validate_inclusion_of(:role).in_array(AdminUser::ROLES) }

  describe "#god?" do
    it { is_expected.not_to be_god }
    it { is_expected.to be_is "Admin" }

    context "when super-admin" do
      subject(:admin) { create :super_admin }

      it { is_expected.to be_god }
      it { is_expected.to be_is "Super" }
    end
  end

  describe "#admin_search" do
    it { expect(described_class.admin_search(admin.first_name)).to include(admin) }
  end
end
