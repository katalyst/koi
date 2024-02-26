# frozen_string_literal: true

require "rails_helper"

describe Koi::SummaryList::NumberComponent do
  subject(:component) { Koi::SummaryListComponent.new(model:) }

  let(:model) { create(:post) }

  include ActionView::Helpers::TagHelper

  describe "#number" do
    let(:render) do
      render_inline(component) do |dl|
        dl.number(:id)
      end
    end

    before { render }

    it { expect(page).to have_css("dt", text: "Id") }
    it { expect(page).to have_css("dt + dd", text: model.id.to_s) }

    context "with blank" do
      let(:model) { build(:post) }

      it { expect(page).not_to have_css("dt") }
    end

    context "with blank and skip_blank: false on the list" do
      subject(:component) { Koi::SummaryListComponent.new(model:, skip_blank: false) }

      let(:model) { build(:post) }

      it { expect(page).to have_css("dt + dd", text: "") }
    end

    context "with blank and skip_blank: false on the item" do
      let(:model) { build(:post) }

      let(:render) do
        render_inline(component) do |dl|
          dl.text(:id, skip_blank: false)
        end
      end

      it { expect(page).to have_css("dt + dd", text: "") }
    end

    context "with block" do
      let(:render) do
        render_inline(component) do |dl|
          dl.number(:id) { |cell| tag.em(cell) }
        end
      end

      it { expect(page).to have_css("dt", text: "Id") }
      it { expect(page).to have_css("dt + dd > em", text: model.id.to_s) }
    end
  end
end
