# frozen_string_literal: true

require "rails_helper"

RSpec.describe Koi::Tables::Cells::LinkComponent do
  let(:table) { Koi::TableComponent.new(collection:) }
  let(:collection) { create_list(:announcement, 1) }
  let(:rendered) { render_inline(table) { |row, _| row.link(:name) } }
  let(:label) { rendered.at_css("thead th") }
  let(:data) { rendered.at_css("tbody td") }

  it "renders column header" do
    expect(label).to match_html(<<~HTML)
      <th class="type-link">Name</th>
    HTML
  end

  it "renders column data" do
    expect(data).to match_html(<<~HTML)
      <td class="type-link"><a href="/admin/announcements/#{collection.first.id}">#{collection.first.name}</a></td>
    HTML
  end

  context "with html_options" do
    let(:rendered) { render_inline(table) { |row| row.link(:name, **Test::HTML_ATTRIBUTES) } }

    it "renders header with html_options" do
      expect(label).to match_html(<<~HTML)
        <th id="ID" class="type-link CLASS" style="style" data-foo="bar" aria-label="LABEL">Name</th>
      HTML
    end

    it "renders data with html_options" do
      expect(data).to match_html(<<~HTML)
        <td id="ID" class="type-link CLASS" style="style" data-foo="bar" aria-label="LABEL"><a href="/admin/announcements/#{collection.first.id}">#{collection.first.name}</a></td>
      HTML
    end
  end

  context "when given a label" do
    let(:rendered) { render_inline(table) { |row| row.link(:name, label: "LABEL") } }

    it "renders header with label" do
      expect(label).to match_html(<<~HTML)
        <th class="type-link">LABEL</th>
      HTML
    end

    it "renders data without label" do
      expect(data).to match_html(<<~HTML)
        <td class="type-link"><a href="/admin/announcements/#{collection.first.id}">#{collection.first.name}</a></td>
      HTML
    end
  end

  context "when given an empty label" do
    let(:rendered) { render_inline(table) { |row| row.link(:name, label: "") } }

    it "renders header with an empty label" do
      expect(label).to match_html(<<~HTML)
        <th class="type-link"></th>
      HTML
    end
  end

  context "with nil data value" do
    let(:rendered) { render_inline(table) { |row| row.link(:name) } }
    let(:collection) { build_list(:announcement, 1, name: nil) }

    it "renders link without content" do
      expect(data).to match_html(<<~HTML)
        <td class="type-link"><a href="/admin/announcements"></a></td>
      HTML
    end
  end

  context "when given a block" do
    let(:rendered) { render_inline(table) { |row| row.link(:name) { |cell| cell.tag.span(cell) } } }

    it "renders the default header" do
      expect(label).to match_html(<<~HTML)
        <th class="type-link">Name</th>
      HTML
    end

    it "renders the custom data" do
      expect(data).to match_html(<<~HTML)
        <td class="type-link"><a href="/admin/announcements/#{collection.first.id}"><span>#{collection.first.name}</span></a></td>
      HTML
    end
  end
end
