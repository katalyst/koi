# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::User do
  subject(:admin) { create(:admin) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:email) }

  it { is_expected.to have_many(:credentials).class_name("Admin::Credential").dependent(:destroy) }

  it { is_expected.to allow_values("a@b.com").for(:email) }
  it { is_expected.not_to allow_values("@b.com", "fail").for(:email) }

  describe "#admin_search" do
    it { expect(described_class.admin_search(admin.name)).to include(admin) }
    it { expect(described_class.admin_search(admin.email)).to include(admin) }
  end
end
