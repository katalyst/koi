# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::Session do
  describe ".from_request" do
    subject(:admin_session) { described_class.from_request(request) }

    let(:request) { ActionDispatch::TestRequest.create }

    context "with a valid admin session cookie" do
      let!(:session_record) { admin.sessions.create!(ip_address: "127.0.0.1", user_agent: "RSpec") }
      let(:admin) { create(:admin) }

      before do
        request.cookie_jar.signed[described_class::COOKIE_NAME] = session_record.id
      end

      it { is_expected.to eq(session_record) }
    end

    context "with no admin session cookie" do
      it { is_expected.to be_nil }
    end

    context "with a deleted admin session" do
      before do
        request.cookie_jar.signed[described_class::COOKIE_NAME] = 999_999
      end

      it { is_expected.to be_nil }
    end
  end
end
