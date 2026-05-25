# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::Session do
  subject(:session) { admin_user.sessions.build }

  let(:admin_user) { create(:admin_user) }

  it { is_expected.to belong_to(:admin).class_name("Admin::User") }
end
