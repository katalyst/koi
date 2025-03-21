# frozen_string_literal: true

require "rails_helper"

describe Koi::Header::NewComponent do
  subject(:component) { described_class.new(model: Admin::User) }

  let(:content) { nil }
  let(:page) do
    with_request_url "/admin/admin_users/new" do
      render_inline(component, &content)
    end
    Capybara::Node::Simple.new(rendered_content)
  end

  it "renders name as title" do
    expect(page).to have_css "h1", text: "New admin"
  end

  context "with a title" do
    subject(:component) { described_class.new(model: Admin::User, title: "Special") }

    it "renders title" do
      expect(page).to have_css "h1", text: "Special"
    end
  end

  it "renders index breadcrumb" do
    expect(page.find_all(".breadcrumbs a").map { |a| [a.text, a[:href]] })
      .to contain_exactly(%w[Admins /admin/admin_users])
  end

  it "does not render any related actions" do
    expect(page).to have_no_css(".related a")
  end

  context "with a parent" do
    let(:content) do
      Proc.new { |component| component.with_breadcrumb("Admin", "/admin") }
    end

    it "renders parent breadcrumb" do
      expect(page.find_all(".breadcrumbs a").map { |a| [a.text, a[:href]] })
        .to contain_exactly(%w[Admin /admin], %w[Admins /admin/admin_users])
    end
  end
end
