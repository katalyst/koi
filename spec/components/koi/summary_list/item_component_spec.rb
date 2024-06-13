# frozen_string_literal: true

require "rails_helper"

# @deprecated legacy interface for Koi 4.0-era definition lists
describe Koi::SummaryList::ItemComponent do
  subject(:component) { Koi::SummaryListComponent.new(model:) }

  let(:model) { create(:post) }

  describe "#item" do
    subject(:component) { Koi::SummaryListComponent.new(class: "item-table") }

    let(:body) { ->(component) { component.item(model, :name) } }

    before do
      render_inline(component, &body)
    end

    it { expect(page).to have_css("dt", text: "Name") }
    it { expect(page).to have_css("dt + dd", text: model.name) }

    context "with empty value" do
      let(:model) { create(:post, name: "") }

      it { expect(page).to have_no_css("dt", text: "Name") }
    end

    context "with empty value and skip_blank: false on the list" do
      subject(:component) { Koi::SummaryListComponent.new(class: "item-table", skip_blank: false) }

      let(:model) { create(:post, name: "") }

      it { expect(page).to have_css("dt", text: "Name") }
      it { expect(page).to have_css("dt + dd", text: "") }
    end

    context "with empty value and skip_blank: false on the item" do
      let(:body) { ->(component) { component.item(model, :name, skip_blank: false) } }

      let(:model) { create(:post, name: "") }

      it { expect(page).to have_css("dt", text: "Name") }
      it { expect(page).to have_css("dt + dd", text: "") }
    end

    context "with custom label" do
      let(:body) { ->(component) { component.item(model, :name, label: { text: "Custom" }) } }

      it { expect(page).to have_css("dt", text: "Custom") }
      it { expect(page).to have_css("dt + dd", text: model.name) }
    end

    context "with rich text" do
      let(:body) { ->(component) { component.item(model, :content) } }

      it { expect(page).to have_css("dt", text: "Content") }
      it { expect(page.find("dd > div").native.to_html).to eq(model.content.to_s.strip) }
    end

    context "with a block for the value" do
      let(:body) do
        Proc.new do |component|
          component.item(model, :name) do |value|
            vc_test_controller.helpers.content_tag(:span, value)
          end
        end
      end

      it { expect(page).to have_css("dt", text: "Name") }
      it { expect(page.find("dd > span").native.to_html).to eq("<span>#{model.name}</span>") }
    end
  end

  describe "#items_with" do
    subject(:component) { Koi::SummaryListComponent.new(class: "item-table") }

    let(:body) { ->(component) { component.items_with(model:, attributes: [:name]) } }

    before do
      render_inline(component, &body)
    end

    it { expect(page).to have_css("dt", text: "Name") }
    it { expect(page).to have_css("dt + dd", text: model.name) }
  end
end
