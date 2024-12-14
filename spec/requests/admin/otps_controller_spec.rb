# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::OtpsController do
  subject { action && response }

  let(:admin) { create(:admin, otp_secret: nil) }

  include_context "with admin session"

  describe "GET /admin/admin_users/:admin_user_id/otp/new" do
    let(:action) { get new_admin_admin_user_otp_path(admin), as: :turbo_stream }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end

    context "with another user's id" do
      let(:session_for) { create(:admin) }

      it "returns an error" do
        action
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "POST /admin/admin_users/:admin_user_id/otp" do
    let(:action) do
      admin.otp_secret = ROTP::Base32.random

      post admin_admin_user_otp_path(admin),
           params: { admin: { otp_secret: admin.otp_secret, token: admin.otp.now } },
           as:     :turbo_stream
    end

    it_behaves_like "requires admin"

    it "redirects to user" do
      action
      expect(response).to have_http_status(:see_other).and(redirect_to(admin_admin_user_path(admin)))
    end

    it "sets otp secret" do
      expect { action }.to(change { admin.reload.otp_secret })
    end

    context "with token mismatch" do
      let(:action) do
        admin.otp_secret = ROTP::Base32.random

        post admin_admin_user_otp_path(admin),
             params: { admin: { otp_secret: admin.otp_secret, token: "000000" } },
             as:     :turbo_stream
      end

      it "updates the form" do
        action
        html = Nokogiri::HTML.fragment(response.body)
        root = Capybara::Node::Simple.new(html)
        expect(root).to have_css("turbo-stream[action='replace'][target='otp_admin_#{admin.id}']")
      end

      it "uses the same secret when re-rendering" do
        action
        html = Nokogiri::HTML.fragment(response.body)
        secret = html.at_css("input[name='admin[otp_secret]']")
        expect(secret.attributes["value"].value).to eq(admin.otp_secret)
      end

      it "does not set the otp secret" do
        expect { action }.not_to(change { admin.reload.otp_secret })
      end
    end
  end

  describe "DELETE /admin/admin_users/:id/otp" do
    let(:action) do
      delete admin_admin_user_otp_path(admin), as: :turbo_stream
    end

    let(:admin) { create(:admin) }

    it_behaves_like "requires admin"

    it "removes the otp secret" do
      expect { action }.to(change { admin.reload.otp_secret }.to(nil))
    end
  end
end
