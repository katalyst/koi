# frozen_string_literal: true

require "rails_helper"

describe Koi::Header::ShowComponent do
  subject(:component) { described_class.new(resource:) }

  let(:content) { nil }
  let(:page) do
    with_request_url "/admin/admin_users/#{resource.id}" do
      render_inline(component, &content)
    end
    Capybara::Node::Simple.new(rendered_content)
  end
  let(:resource) { create :admin }

  it "renders name as title" do
    expect(page).to have_css "h1", text: resource.name
  end

  context "with a title" do
    subject(:component) { described_class.new(resource:, title: "Special") }

    it "renders title" do
      expect(page).to have_css "h1", text: "Special"
    end
  end

  it "renders index breadcrumb" do
    expect(page.find_all("div[class='breadcrumbs'] a").map { |a| [a.text, a[:href]] })
      .to contain_exactly(%w[Admins /admin/admin_users])
  end

  it "renders edit action" do
    expect(page.find_all("div[class='actions'] a").map { |a| [a.text, a[:href]] })
      .to contain_exactly(%W[Edit /admin/admin_users/#{resource.id}/edit])
  end

  context "when edit is not available" do
    before do
      # rubocop:disable RSpec/SubjectStub
      allow(component).to receive(:url_for).and_call_original
      allow(component).to receive(:url_for).with(action: :edit) do
        raise ActionController::UrlGenerationError.new("Not found (test)")
      end
      # rubocop:enable RSpec/SubjectStub
    end

    it "does not render show link" do
      expect(page).not_to have_css("div[class='actions'] a")
    end
  end

  context "with a parent resource" do
    let(:content) do
      Proc.new { |component| component.with_breadcrumb("Admin", "/admin") }
    end

    it "renders parent breadcrumbs" do
      expect(page.find_all("div[class='breadcrumbs'] a").map { |a| [a.text, a[:href]] })
        .to contain_exactly(%w[Admin /admin], %w[Admins /admin/admin_users])
    end
  end
end
