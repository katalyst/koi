# frozen_string_literal: true

require "rails_helper"

describe ResourceHeaderComponent do
  let(:page) do
    with_request_url url[0] do
      vc_test_controller.action_name = url[1].to_s
      render_inline(component)
    end
    Capybara::Node::Simple.new(rendered_content)
  end

  let(:resource) { create :admin }

  describe "resource#index" do
    subject(:component) { described_class.new(model: Admin::User) }

    let(:url) { ["/admin/admin_users", :index] }

    it "renders name as title" do
      expect(page).to have_css "h1", text: "Admins"
    end

    it "does not render any breadcrumbs" do
      expect(page).not_to have_css("div[class='breadcrumbs'] a")
    end

    it "does not render any actions" do
      expect(page).not_to have_css("div[class='actions'] a")
    end
  end

  describe "resource#show" do
    subject(:component) { described_class.new(resource:) }

    let(:url) { ["/admin/admin_users/#{resource.id}", :show] }

    it "renders name as title" do
      expect(page).to have_css "h1", text: resource.name
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
        allow(component).to receive(:url_for).and_call_original
        allow(component).to receive(:url_for).with(action: :edit) { raise ActionController::UrlGenerationError.new("Not found (test)") }
      end

      it "does not render show link" do
        expect(page).not_to have_css("div[class='actions'] a")
      end
    end
  end

  describe "resource#edit" do
    subject(:component) { described_class.new(resource:) }

    let(:url) { ["/admin/admin_users/#{resource.id}/edit", :edit] }

    it "renders name as title" do
      expect(page).to have_css "h1", text: "Edit admin"
    end

    it "renders index and show links" do
      expect(page.find_all("div[class='breadcrumbs'] a").map { |a| [a.text, a[:href]] })
        .to contain_exactly(%w[Admins /admin/admin_users], [resource.name, "/admin/admin_users/#{resource.id}"])
    end

    it "does not render any actions" do
      expect(page).not_to have_css("div[class='actions'] a")
    end

    context "when show is not available" do
      before do
        allow(component).to receive(:url_for).and_call_original
        allow(component).to receive(:url_for).with(action: :show) { raise ActionController::UrlGenerationError.new("Not found (test)") }
      end

      it "does not render show link" do
        expect(page.find_all("div[class='breadcrumbs'] a").map { |a| [a.text, a[:href]] })
          .to contain_exactly(%w[Admins /admin/admin_users])
      end
    end
  end

  describe "resource#new" do
    subject(:component) { described_class.new(model: Admin::User) }

    let(:url) { ["/admin/admin_users/#{resource.id}", :new] }

    it "renders name as title" do
      expect(page).to have_css "h1", text: "New admin"
    end

    it "renders index breadcrumb" do
      expect(page.find_all("div[class='breadcrumbs'] a").map { |a| [a.text, a[:href]] })
        .to contain_exactly(%w[Admins /admin/admin_users])
    end

    it "does not render any actions" do
      expect(page).not_to have_css("div[class='actions'] a")
    end
  end
end
