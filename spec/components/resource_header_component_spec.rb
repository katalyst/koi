# frozen_string_literal: true

require "rails_helper"

describe ResourceHeaderComponent do
  let(:resource) { create :admin }

  context "with admin index" do
    before do
      with_request_url "/admin/admin_users" do
        vc_test_controller.action_name = "index"
        render_inline(described_class.new(model: Admin::User))
      end
    end

    it "renders name as title" do
      expect(page).to have_css "h1", text: "Admins"
    end

    it "does not render any breadcrumbs" do
      expect(page.find_all("div[class='breadcrumbs'] a").map { |a| [a.text, a[:href]] }).to be_empty
    end

    it "does not render any actions" do
      expect(page.find_all("div[class='actions'] a").map { |a| [a.text, a[:href]] }).to be_empty
    end
  end

  context "with admin show" do
    before do
      with_request_url "/admin/admin_users/#{resource.id}" do
        vc_test_controller.action_name = "show"
        render_inline(described_class.new(resource:))
      end
    end

    it "renders name as title" do
      expect(page).to have_css "h1", text: resource.name
    end

    it "renders index breadcrumb" do
      expect(page.find_all("div[class='breadcrumbs'] a").map { |a| [a.text, a[:href]] })
        .to contain_exactly(%w[Admins /admin/admin_users])
    end

    it "does not render show breadcrumb" do
      expect(page).not_to have_css "a[href='/admin/admin_users/#{resource.id}']"
    end

    it "renders edit action" do
      expect(page.find_all("div[class='actions'] a").map { |a| [a.text, a[:href]] })
        .to contain_exactly(%W[Edit /admin/admin_users/#{resource.id}/edit])
    end
  end

  context "with admin edit" do
    before do
      with_request_url "/admin/admin_users/#{resource.id}/edit" do
        vc_test_controller.action_name = "edit"
        render_inline(described_class.new(resource:))
      end
    end

    it "renders name as title" do
      expect(page).to have_css "h1", text: "Edit admin"
    end

    it "renders index and show links" do
      expect(page.find_all("div[class='breadcrumbs'] a").map { |a| [a.text, a[:href]] })
        .to contain_exactly(%w[Admins /admin/admin_users], [resource.name, "/admin/admin_users/#{resource.id}"])
    end

    it "does not render any actions" do
      expect(page.find_all("div[class='actions'] a").map { |a| [a.text, a[:href]] }).to be_empty
    end
  end

  context "with admin new" do
    before do
      with_request_url "/admin/admin_users/new" do
        vc_test_controller.action_name = "new"
        render_inline(described_class.new(resource: build(:admin)))
      end
    end

    it "renders name as title" do
      expect(page).to have_css "h1", text: "New admin"
    end

    it "renders index breadcrumb" do
      expect(page.find_all("div[class='breadcrumbs'] a").map { |a| [a.text, a[:href]] })
        .to contain_exactly(%w[Admins /admin/admin_users])
    end

    it "does not render any actions" do
      expect(page.find_all("div[class='actions'] a").map { |a| [a.text, a[:href]] }).to be_empty
    end
  end
end
