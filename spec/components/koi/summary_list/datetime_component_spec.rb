# frozen_string_literal: true

require "rails_helper"

describe Koi::SummaryList::DatetimeComponent do
  subject(:component) { Koi::SummaryListComponent.new(model:) }

  let(:model) { create(:post) }

  describe "#datetime" do
    let(:render) do
      render_inline(component) do |dl|
        dl.datetime(:updated_at)
      end
    end

    before { render }

    it { expect(page).to have_css("dt", text: "Updated at") }
    it { expect(page).to have_css("dt + dd", text: I18n.l(model.updated_at, format: :admin)) }

    context "with format" do
      let(:render) do
        render_inline(component) do |dl|
          dl.datetime(:updated_at, format: :short)
        end
      end

      it { expect(page).to have_css("dt + dd", text: I18n.l(model.updated_at, format: :short)) }
    end

    context "with blank" do
      let(:model) { build(:post) }

      it { expect(page).not_to have_css("dt") }
    end

    context "with blank and skip_blank: false" do
      subject(:component) { Koi::SummaryListComponent.new(model:, skip_blank: false) }

      let(:model) { build(:post) }

      it { expect(page).to have_css("dt + dd", text: "") }
    end
  end
end
