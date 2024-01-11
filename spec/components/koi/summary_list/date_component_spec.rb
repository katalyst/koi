# frozen_string_literal: true

require "rails_helper"

describe Koi::SummaryList::DateComponent do
  subject(:component) { Koi::SummaryListComponent.new(model:) }

  let(:model) { create(:post) }

  describe "#date" do
    let(:render) do
      render_inline(component) do |dl|
        dl.date(:published_on)
      end
    end

    before { render }

    it { expect(page).to have_css("dt", text: "Published on") }
    it { expect(page).to have_css("dt + dd", text: I18n.l(model.published_on, format: :admin)) }

    context "with format" do
      let(:render) do
        render_inline(component) do |dl|
          dl.date(:published_on, format: :short)
        end
      end

      it { expect(page).to have_css("dt + dd", text: I18n.l(model.published_on, format: :short)) }
    end

    context "with blank" do
      let(:model) { create(:post, published_on: nil) }

      it { expect(page).not_to have_css("dt") }
    end

    context "with blank and skip_blank: false" do
      subject(:component) { Koi::SummaryListComponent.new(model:, skip_blank: false) }

      let(:model) { create(:post, published_on: nil) }

      it { expect(page).to have_css("dt + dd", text: "") }
    end
  end
end
