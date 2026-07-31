# frozen_string_literal: true

require "rails_helper"

RSpec.describe Koi::FormBuilder do
  subject(:builder) { described_class.new(:banner, Banner.new, helper, {}) }

  describe "#govuk_image_field" do
    it "posts direct uploads to Koi's authorised admin endpoint" do
      expect(builder.govuk_image_field(:image)).to have_css(
        "input[type=file][data-direct-upload-url='#{helper.main_app.admin_direct_uploads_url}']",
        visible: :all,
      )
    end
  end

  context "with a rich text attribute" do
    subject(:builder) { described_class.new(:announcement, Announcement.new, helper, {}) }

    describe "#lexxy_rich_textarea" do
      it "posts direct uploads to Koi's authorised admin endpoint" do
        expect(builder.lexxy_rich_textarea(:content)).to have_css(
          "lexxy-editor[data-direct-upload-url='#{helper.main_app.admin_direct_uploads_url}']",
          visible: :all,
        )
      end
    end

    describe "#trix_rich_textarea" do
      it "posts direct uploads to Koi's authorised admin endpoint" do
        expect(builder.trix_rich_textarea(:content)).to have_css(
          "trix-editor[data-direct-upload-url='#{helper.main_app.admin_direct_uploads_url}']",
          visible: :all,
        )
      end
    end
  end
end
