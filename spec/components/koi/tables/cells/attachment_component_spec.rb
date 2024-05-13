# frozen_string_literal: true

require "rails_helper"

RSpec.describe Koi::Tables::Cells::AttachmentComponent do
  let(:table) { Koi::Tables::TableComponent.new(collection:) }
  let(:collection) { create_list(:banner, 1, :with_image) }
  let(:rendered) { render_inline(table) { |row| row.attachment(:image) } }
  let(:label) { rendered.at_css("thead th") }
  let(:data) { rendered.at_css("tbody td") }

  it "renders column header" do
    expect(label).to match_html(<<~HTML)
      <th class="type-attachment">Image</th>
    HTML
  end

  it "renders column data" do
    expect(data).to have_css("td.type-attachment img[src*='dummy.png']")
  end

  context "with html_options" do
    let(:rendered) { render_inline(table) { |row| row.attachment(:image, **Test::HTML_ATTRIBUTES) } }

    it "renders header with html_options" do
      expect(label).to match_html(<<~HTML)
        <th id="ID" class="type-attachment CLASS" style="style" data-foo="bar" aria-label="LABEL">Image</th>
      HTML
    end

    it "renders data with html_options" do
      expect(data).to have_css("td.type-attachment.CLASS[data-foo=bar] img[src*='dummy.png']")
    end
  end

  context "when given a label" do
    let(:rendered) { render_inline(table) { |row| row.attachment(:image, label: "LABEL") } }

    it "renders header with label" do
      expect(label).to match_html(<<~HTML)
        <th class="type-attachment">LABEL</th>
      HTML
    end

    it "renders data without label" do
      expect(data).to have_css("td.type-attachment img[src*='dummy.png']")
    end
  end

  context "when given an empty label" do
    let(:rendered) { render_inline(table) { |row| row.attachment(:image, label: "") } }

    it "renders header with an empty label" do
      expect(label).to match_html(<<~HTML)
        <th class="type-attachment"></th>
      HTML
    end
  end

  context "with nil data value" do
    let(:collection) { build_list(:banner, 1) }

    it "renders data as falsey" do
      expect(data).to match_html(<<~HTML)
        <td class="type-attachment"></td>
      HTML
    end
  end

  context "when given a block" do
    let(:rendered) { render_inline(table) { |row| row.attachment(:image) { |cell| cell.tag.span(cell) } } }

    it "renders the default header" do
      expect(label).to match_html(<<~HTML)
        <th class="type-attachment">Image</th>
      HTML
    end

    it "renders the custom data" do
      expect(data).to have_css("td.type-attachment > span > img[src*='dummy.png']")
    end
  end
end
