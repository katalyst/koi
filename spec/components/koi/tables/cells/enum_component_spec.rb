# frozen_string_literal: true

require "rails_helper"

RSpec.describe Koi::Tables::Cells::EnumComponent do
  let(:table) { Koi::TableComponent.new(collection:) }
  let(:collection) { create_list(:banner, 1, status: "published") }
  let(:rendered) { render_inline(table) { |row, _post| row.enum(:status) } }
  let(:label) { rendered.at_css("thead th") }
  let(:data) { rendered.at_css("tbody td") }

  it "renders column header" do
    expect(label).to match_html(<<~HTML)
      <th class="type-enum">Status</th>
    HTML
  end

  it "renders column data" do
    expect(data).to match_html(<<~HTML)
      <td class="type-enum"><span data-enum="status" data-value="published">Published</span></td>
    HTML
  end

  context "with html_options" do
    let(:rendered) { render_inline(table) { |row| row.enum(:status, **Test::HTML_ATTRIBUTES) } }

    it "renders header with html_options" do
      expect(label).to match_html(<<~HTML)
        <th id="ID" class="type-enum CLASS" style="style" data-foo="bar" aria-label="LABEL">Status</th>
      HTML
    end

    it "renders data with html_options" do
      expect(data).to match_html(<<~HTML)
        <td id="ID" class="type-enum CLASS" style="style" data-foo="bar" aria-label="LABEL"><span data-enum="status" data-value="published">Published</span></td>
      HTML
    end
  end

  context "when given a label" do
    let(:rendered) { render_inline(table) { |row| row.enum(:status, label: "LABEL") } }

    it "renders header with label" do
      expect(label).to match_html(<<~HTML)
        <th class="type-enum">LABEL</th>
      HTML
    end

    it "renders data without label" do
      expect(data).to match_html(<<~HTML)
        <td class="type-enum"><span data-enum="status" data-value="published">Published</span></td>
      HTML
    end
  end

  context "when given an empty label" do
    let(:rendered) { render_inline(table) { |row| row.enum(:status, label: "") } }

    it "renders header with an empty label" do
      expect(label).to match_html(<<~HTML)
        <th class="type-enum"></th>
      HTML
    end
  end

  context "with nil data value" do
    let(:rendered) { render_inline(table) { |row| row.enum(:status) } }
    let(:collection) { create_list(:banner, 1, status: nil) }

    it "renders an empty cell" do
      expect(data).to match_html(<<~HTML)
        <td class="type-enum"></td>
      HTML
    end
  end

  context "when given a block" do
    let(:rendered) { render_inline(table) { |row| row.enum(:status) { |cell| cell.tag.span(cell) } } }

    it "renders the default header" do
      expect(label).to match_html(<<~HTML)
        <th class="type-enum">Status</th>
      HTML
    end

    it "renders the custom data" do
      expect(data).to match_html(<<~HTML)
        <td class="type-enum"><span><span data-enum="status" data-value="published">Published</span></span></td>
      HTML
    end
  end
end
