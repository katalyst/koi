# frozen_string_literal: true

require "rails_helper"

describe Koi::SummaryList::RichTextComponent do
  subject(:component) { Koi::SummaryListComponent.new(model:) }

  let(:model) { create(:post) }

  include ActionView::Helpers::TagHelper

  describe "#rich_text" do
    let(:render) do
      render_inline(component) do |dl|
        dl.rich_text(:content)
      end
    end

    before { render }

    it { expect(page).to have_css("dt", text: "Content") }
    it { expect(page.find("dd > div").native.to_html).to eq(model.content.to_s.strip) }

    context "with block" do
      let(:render) do
        render_inline(component) do |dl|
          dl.rich_text(:content) { |cell| tag.pre(cell) }
        end
      end

      it { expect(page).to have_css("dt", text: "Content") }
      it { expect(page.find("dd > pre > div").native.to_html).to eq(model.content.to_s.strip) }
    end
  end
end
