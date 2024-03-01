# frozen_string_literal: true

require "rails_helper"

describe Koi::Tables::Header do
  let(:table) { Koi::Tables::TableComponent.new(collection:, id: "table") }
  let(:collection) { Post.all }

  describe Koi::Tables::Header::BooleanComponent do
    it "renders column header" do
      component = described_class.new(table, :active)
      rendered  = render_inline(component)
      expect(rendered).to match_html(<<~HTML)
        <th class="type-boolean">Active</th>
      HTML
    end

    context "when width is specified" do
      it "renders column header" do
        component = described_class.new(table, :active, width: :m)
        rendered  = render_inline(component)
        expect(rendered).to match_html(<<~HTML)
          <th class="width-m type-boolean">Active</th>
        HTML
      end
    end

    context "when additional css class is specified" do
      it "renders column header" do
        component = described_class.new(table, :active, class: "custom-class")
        rendered  = render_inline(component)
        expect(rendered).to match_html(<<~HTML)
          <th class="type-boolean custom-class">Active</th>
        HTML
      end
    end
  end

  describe Koi::Tables::Header::NumberComponent do
    let(:collection) { Banner.all }

    it "renders column header" do
      component = described_class.new(table, :ordinal)
      rendered  = render_inline(component)
      expect(rendered).to match_html(<<~HTML)
        <th class="type-number">Ordinal</th>
      HTML
    end

    context "with sorting" do
      let(:collection) { Katalyst::Tables::Collection::Base.new(sorting: "ordinal desc").apply(Banner.all) }

      it "renders column header" do
        component = described_class.new(table, :ordinal)
        rendered  = render_inline(component)
        expect(rendered).to match_html(<<~HTML)
          <th data-sort="desc" class="type-number">
            <a href="/?sort=ordinal+asc">Ordinal</a>
          </th>
        HTML
      end
    end

    context "with custom class and sorting" do
      let(:collection) { Katalyst::Tables::Collection::Base.new(sorting: "ordinal desc").apply(Banner.all) }

      it "renders column header" do
        component = described_class.new(table, :ordinal, class: "custom-class")
        rendered  = render_inline(component)
        expect(rendered).to match_html(<<~HTML)
          <th data-sort="desc" class="type-number custom-class">
            <a href="/?sort=ordinal+asc">Ordinal</a>
          </th>
        HTML
      end
    end
  end
end
