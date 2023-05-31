# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::Credential do
  subject(:credential) { create(:admin).credentials.build(nickname: "test") }

  it { is_expected.to validate_presence_of(:external_id) }
  it { is_expected.to validate_presence_of(:public_key) }
  it { is_expected.to validate_presence_of(:nickname) }
  it { is_expected.to validate_presence_of(:sign_count) }

  it { is_expected.to belong_to(:admin).class_name("Admin::User") }
end
