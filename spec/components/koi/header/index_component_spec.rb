# frozen_string_literal: true

require "rails_helper"

describe Koi::Header::IndexComponent do
  subject(:component) { described_class.new(model: Admin::User) }

  let(:content) { nil }
  let(:page) do
    with_request_url "/admin/admin_users" do
      render_inline(component, &content)
    end
    Capybara::Node::Simple.new(rendered_content)
  end
  let(:resource) { create(:admin) }

  it "renders name as title" do
    expect(page).to have_css "h1", text: "Admins"
  end

  context "with a title" do
    subject(:component) { described_class.new(model: Admin::User, title: "Special") }

    it "renders title" do
      expect(page).to have_css "h1", text: "Special"
    end
  end

  it "does not render any breadcrumbs" do
    expect(page).to have_no_css("div[class='breadcrumbs'] a")
  end

  it "does not render any actions" do
    expect(page).to have_no_css("div[class='actions'] a")
  end

  context "with a parent" do
    let(:content) do
      Proc.new { |component| component.with_breadcrumb("Admin", "/admin") }
    end

    it "renders parent breadcrumb" do
      expect(page.find_all("div[class='breadcrumbs'] a").map { |a| [a.text, a[:href]] })
        .to contain_exactly(%w[Admin /admin])
    end
  end
end
