# frozen_string_literal: true

require "rails_helper"

describe Koi::Tables::Body do
  include Rails.application.routes.url_helpers

  let(:record) { create(:post) }
  let(:table) { Koi::Tables::TableComponent.new(collection: Post.all, id: "table") }

  before do
    record
  end

  describe Koi::Tables::Body::LinkComponent do
    it "renders column" do
      component = described_class.new(table, record, :name, url: [:admin, record])
      rendered  = render_inline(component)
      expect(rendered).to match_html(<<~HTML)
        <td>
          <a href="/admin/posts/#{record.id}">#{record.name}</a>
        </td>
      HTML
    end

    it "supports path helpers" do
      component = described_class.new(table, record, :name, url: :edit_admin_post_path)
      rendered  = render_inline(component)
      expect(rendered).to match_html(<<~HTML)
        <td>
          <a href="/admin/posts/#{record.id}/edit">#{record.name}</a>
        </td>
      HTML
    end

    it "supports procs" do
      record    = create(:url_rewrite, to: "www.example.com")
      component = described_class.new(table, record, :from, url: ->(object) { object.to })
      rendered  = render_inline(component)
      expect(rendered).to match_html(<<~HTML)
        <td>
          <a href="www.example.com">#{record.from}</a>
        </td>
      HTML
    end

    it "supports content" do
      component = described_class.new(table, record, :name, url: [:admin, record])
                    .with_content("Redirect from #{record.name}")
      rendered  = render_inline(component)
      expect(rendered).to match_html(<<~HTML)
        <td>
          <a href="#{polymorphic_path([:admin, record])}">Redirect from #{record.name}</a>
        </td>
      HTML
    end

    it "supports attributes for anchor tag" do
      component = described_class.new(table, record, :name, url: [:admin, record], link: { class: "custom" })
      rendered  = render_inline(component)
      expect(rendered).to match_html(<<~HTML)
        <td>
          <a class="custom" href="#{polymorphic_path([:admin, record])}">#{record.name}</a>
        </td>
      HTML
    end
  end

  describe Koi::Tables::Body::ImageComponent do
    it "renders column" do
      record    = create(:banner, :with_image)
      component = described_class.new(table, record, :image)
      rendered  = render_inline(component)
      expect(rendered).to have_css("td > img[src*='dummy.png']")
    end
  end

  describe Koi::Tables::Body::RichTextComponent do
    it "renders column" do
      component = described_class.new(table, record, :content)
      rendered  = render_inline(component)
      expect(rendered).to match_html(<<~HTML)
        <td title="#{record.content.to_plain_text}">#{record.content}</td>
      HTML
    end
  end

  describe Koi::Tables::Body::BooleanComponent do
    it "renders column" do
      component = described_class.new(table, record, :active)
      rendered  = render_inline(component)
      expect(rendered).to match_html(<<~HTML)
        <td>Yes</td>
      HTML
    end
  end

  describe Koi::Tables::Body::DateComponent do
    it "renders column" do
      component = described_class.new(table, record, :published_on)
      rendered  = render_inline(component)
      expect(rendered).to match_html(<<~HTML)
        <td>#{I18n.l(record.published_on, format: :admin)}</td>
      HTML
    end
  end

  describe Koi::Tables::Body::DatetimeComponent do
    it "renders column" do
      component = described_class.new(table, record, :created_at)
      rendered  = render_inline(component)
      expect(rendered).to match_html(<<~HTML)
        <td>#{I18n.l(record.created_at, format: :admin)}</td>
      HTML
    end
  end

  describe Koi::Tables::Body::NumberComponent do
    it "renders column" do
      record    = create(:banner)
      component = described_class.new(table, record, :ordinal)
      rendered  = render_inline(component)
      expect(rendered).to match_html(<<~HTML)
        <td class="number">#{record.ordinal}</td>
      HTML
    end
  end
end
