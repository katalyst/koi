# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::ActiveStorage::DirectUploadsController do
  subject { action && response }

  let(:action) { post admin_direct_uploads_path, params:, headers: }
  let(:headers) { {} }
  let(:file) { StringIO.new("test") }
  let(:params) do
    {
      blob: {
        filename:     "fringe.jpg",
        content_type: "image/jpeg",
        byte_size:    file.size,
        checksum:     OpenSSL::Digest::MD5.new(file.read).base64digest,
      },
    }
  end

  it { is_expected.to have_http_status(:see_other).and(redirect_to(new_admin_session_path)) }
  it { expect { action }.not_to change(ActiveStorage::Blob, :count) }

  context "with an admin session" do
    include_context "with admin session"

    it { is_expected.to be_successful }
    it { expect { action }.to change(ActiveStorage::Blob, :count).by(1) }
  end

  context "with an admin API token" do
    let(:headers) { { "Authorization" => "Bearer #{access_token}" } }
    let(:device_authorization) { create(:admin_device_authorization, :approved) }
    let(:access_token) { device_authorization.generate_token_for(:api_access) }

    before do
      device_authorization.consume!
    end

    it { is_expected.to be_successful }
    it { expect { action }.to change(ActiveStorage::Blob, :count).by(1) }
  end
end
