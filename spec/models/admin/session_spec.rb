# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::Session do
  subject(:session) { admin_user.sessions.build(ip_address: "1.2.3.4", user_agent: "Test Agent") }

  let(:admin_user) { create(:admin_user) }

  it { is_expected.to belong_to(:admin).class_name("Admin::User") }

  it "records sign in metadata" do
    expect { session.save! }.to(change { admin_user.reload.last_sign_in_ip }.to("1.2.3.4"))
  end

  it "records sign out metadata" do
    session.save!

    expect { session.destroy! }.to(change { admin_user.reload.last_sign_out_at })
  end
end
