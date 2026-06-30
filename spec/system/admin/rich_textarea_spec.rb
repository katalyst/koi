# frozen_string_literal: true

require "rails_helper"

RSpec.describe "admin rich textarea integration" do
  before do
    admin = create(:admin)
    visit "/admin"

    fill_in "Email", with: admin.email
    click_on "Next"

    fill_in "Password", with: admin.password
    click_on "Next"

    fill_in "Token", with: admin.otp.now
    click_on "Next"
  end

  context "with the trix editor" do
    it "uploads attachments via the admin direct uploads endpoint" do
      announcement = create(:announcement, content: "testing uploads")

      visit edit_admin_announcement_path(announcement)

      expect(page).to have_css("trix-editor[data-direct-upload-url*='/admin/']")
    end

    it "can add an anchor link" do
      announcement = create(:announcement, content: "testing link editing")

      visit edit_admin_announcement_path(announcement)

      # wait for editor to load
      expect(page).to have_button(text: "Link")

      find("trix-editor").click

      page.execute_script("document.querySelector('trix-editor').editor.setSelectedRange([8, 12])")

      click_on "Link"
      fill_in "Enter a URL…", with: "#anchor"
      within(".trix-dialog.trix-active") { click_on "Link" }

      click_button(type: "submit")

      expect(page).to have_link(text: "link", href: "#anchor")
    end

    it "can add a heading" do
      announcement = create(:announcement, content: "testing headings")

      visit edit_admin_announcement_path(announcement)

      # wait for editor to load
      expect(page).to have_button(text: "Heading")

      find("trix-editor").click

      page.execute_script("document.querySelector('trix-editor').editor.setSelectedRange([0, 0])")

      click_on "Heading"

      click_button(type: "submit")

      # Koi uses h4 for headings rather than the trix default of h1
      expect(page).to have_css("h4", text: "testing headings")
    end

    # regression test for headings not being detected on first interaction
    it "can modify an existing heading" do
      announcement = create(:announcement, content: "<h4>testing headings</h4>")

      visit edit_admin_announcement_path(announcement)

      # wait for editor to load
      expect(page).to have_css("trix-editor h4")

      # ensure heading has correctly identified that the first element is a heading
      expect(page).to have_css("button[data-trix-attribute=heading4]", class: "trix-active")
    end
  end

  context "with the lexxy editor enabled" do
    before { Flipper.enable(:lexxy) }

    it "uploads attachments via the admin direct uploads endpoint" do
      announcement = create(:announcement, content: "testing uploads")

      visit edit_admin_announcement_path(announcement)

      # Koi overrides lexxy's default rails_direct_uploads_url with the admin
      # endpoint, so the URL must end with the admin path rather than /rails/.
      expect(page).to have_css("lexxy-editor[data-direct-upload-url$='/admin/active_storage/direct_uploads']")
      expect(page).to have_no_css("trix-editor")
    end

    it "can add an anchor link" do
      announcement = create(:announcement, content: "testing link editing")

      visit edit_admin_announcement_path(announcement)

      # wait for editor to load
      expect(page).to have_button("Link")

      select_lexxy_range(8, 12)

      click_on "Link"
      # Koi swaps lexxy's type=url link input for a type=text input with the
      # same pattern as trix, so schemeless anchor/relative links pass
      # validation (see koi/utils/lexxy.js).
      fill_in "Enter a URL…", with: "#anchor"
      within("lexxy-link-dropdown [role=dialog]") { click_on "Link" }

      click_button(type: "submit")

      expect(page).to have_link("link", href: "#anchor")
    end

    it "can add a heading" do
      announcement = create(:announcement, content: "testing headings")

      visit edit_admin_announcement_path(announcement)

      # wait for editor to load
      expect(page).to have_button("Text formatting")

      select_lexxy_range(0, 0)

      click_on "Text formatting"
      click_on "Large Heading"

      click_button(type: "submit")

      # lexxy's large heading maps to h2 (no Koi override, unlike trix)
      expect(page).to have_css("h2", text: "testing headings")
    end

    # regression test for headings not being detected on first interaction
    it "can modify an existing heading" do
      announcement = create(:announcement, content: "<h2>testing headings</h2>")

      visit edit_admin_announcement_path(announcement)

      # wait for editor to load
      expect(page).to have_css("lexxy-editor h2")

      select_lexxy_range(0, 0)

      # ensure the toolbar has identified the current block as a large heading
      expect(page).to have_css("button[name=heading-large][aria-pressed=true]", visible: :all)
    end
  end

  # Lexxy has no offset-based selection API like trix's editor.setSelectedRange,
  # so we set a DOM range over the editor's contenteditable and let Lexical sync
  # it into its editor state via the selectionchange event.
  def select_lexxy_range(from, to)
    page.execute_script(<<~JS, from, to)
      const [from, to] = arguments;
      const content = document.querySelector("lexxy-editor .lexxy-editor__content");
      content.focus();
      const textNode = document.createTreeWalker(content, NodeFilter.SHOW_TEXT).nextNode();
      const range = document.createRange();
      range.setStart(textNode, from);
      range.setEnd(textNode, to);
      const selection = window.getSelection();
      selection.removeAllRanges();
      selection.addRange(range);
      document.dispatchEvent(new Event("selectionchange"));
    JS
  end
end
