# frozen_string_literal: true

require "rails_helper"

describe Koi::SummaryList::TextComponent do
  subject(:component) { Koi::SummaryListComponent.new(model:) }

  let(:model) { create(:post) }

  describe "#text" do
    let(:render) do
      render_inline(component) do |dl|
        dl.text(:name)
      end
    end

    before { render }

    it { expect(page).to have_css("dt", text: "Name") }
    it { expect(page).to have_css("dt + dd", text: model.name) }

    context "with blank" do
      let(:model) { create(:post, name: "") }

      it { expect(page).not_to have_css("dt") }
    end

    context "with blank and skip_blank: false on the list" do
      subject(:component) { Koi::SummaryListComponent.new(model:, skip_blank: false) }

      let(:model) { create(:post, name: "") }

      it { expect(page).to have_css("dt + dd", text: model.name) }
    end

    context "with blank and skip_blank: false on the item" do
      let(:model) { create(:post, name: "") }

      let(:render) do
        render_inline(component) do |dl|
          dl.text(:name, skip_blank: false)
        end
      end

      it { expect(page).to have_css("dt + dd", text: model.name) }
    end

    context "with embedded html" do
      let(:model) { create(:post, name: "<strong>Foo</strong>") }

      it { expect(page).to have_css("dt", text: "Name") }
      it { expect(page.find("dt + dd").native.to_html).to eq("<dd>&lt;strong&gt;Foo&lt;/strong&gt;</dd>") }
    end
  end
end
