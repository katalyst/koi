# frozen_string_literal: true

require "rails_helper"

describe Koi::SummaryList::BooleanComponent do
  subject(:component) { Koi::SummaryListComponent.new(model:) }

  let(:model) { create(:post) }

  include ActionView::Helpers::TagHelper

  describe "#boolean" do
    let(:render) do
      render_inline(component) do |dl|
        dl.boolean(:active)
      end
    end

    before { render }

    it { expect(page).to have_css("dt", text: "Active") }
    it { expect(page).to have_css("dt + dd", text: "Yes") }

    context "with label" do
      let(:render) do
        render_inline(component) do |dl|
          dl.boolean(:active, label: { text: "Custom" })
        end
      end

      it { expect(page).to have_css("dt", text: "Custom") }
    end

    context "with false" do
      let(:model) { create(:post, active: false) }

      it { expect(page).to have_css("dt", text: "Active") }
      it { expect(page).to have_css("dt + dd", text: "No") }
    end

    context "with block" do
      let(:render) do
        render_inline(component) do |dl|
          dl.boolean(:active) { |cell| tag.em(cell) }
        end
      end

      it { expect(page).to have_css("dt", text: "Active") }
      it { expect(page).to have_css("dt + dd > em", text: "Yes") }
    end
  end
end
