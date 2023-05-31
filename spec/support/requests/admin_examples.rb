# frozen_string_literal: true

RSpec.shared_context "with admin session" do
  let(:session_for) { admin }

  before do
    if session_for.present?
      post admin_session_path, params: { admin: { email: admin.email, password: admin.password } }
    end
  end
end

RSpec.shared_examples "requires admin" do
  let(:session_for) { nil }

  it "redirects to admin login" do
    action
    expect(response).to redirect_to(new_admin_session_path)
  end
end
