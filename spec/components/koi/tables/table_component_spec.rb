# frozen_string_literal: true

require "rails_helper"

describe Koi::Tables::TableComponent do
  include ActionView::Helpers::NumberHelper
  include Rails.application.routes.url_helpers

  subject(:table) do
    with_request_url("/homepage") do
      vc_test_request.headers["Accept"] = "text/html"
      render_inline(described_class.new(collection:, id: "table"), &content)
    end
  end

  let(:collection) { Katalyst::Tables::Collection::Base.new.apply(Post.all) }
  let(:content) { Proc.new { |row| row.cell :name } }

  before do
    create_list(:post, 1)
    create_list(:banner, 1)
    vc_test_controller.response = instance_double(ActionDispatch::Response, media_type: "text/html")
  end

  it "renders column" do
    expect(table).to match_html(<<~HTML)
      <table data-controller="tables--turbo--collection" data-tables--turbo--collection-query-value="" id="table">
        <thead><tr><th>Name</th></tr></thead>
        <tbody><tr><td>#{collection.items.first&.name}</td></tr></tbody>
      </table>
    HTML
  end

  context "with boolean" do
    let(:content) { Proc.new { |row| row.boolean :active } }

    it "renders boolean column" do
      expect(table).to match_html(<<~HTML)
        <table data-controller="tables--turbo--collection" data-tables--turbo--collection-query-value="" id="table">
          <thead><tr><th class="type-boolean">Active</th></tr></thead>
          <tbody><tr><td>Yes</td></tr></tbody>
        </table>
      HTML
    end

    context "with content" do
      let(:content) do
        Proc.new do |row|
          row.boolean :active do |v|
            v ? "Green" : "Red"
          end
        end
      end

      it "renders boolean column with custom content" do
        expect(table).to match_html(<<~HTML)
          <table data-controller="tables--turbo--collection" data-tables--turbo--collection-query-value="" id="table">
            <thead><tr><th class="type-boolean">Active</th></tr></thead>
            <tbody><tr><td>Green</td></tr></tbody>
          </table>
        HTML
      end
    end
  end

  context "with date" do
    let(:value) { I18n.l(collection.items.first&.published_on, format: :admin) }
    let(:content) { Proc.new { |row| row.date :published_on } }

    it "renders date column" do
      expect(table).to match_html(<<~HTML)
        <table data-controller="tables--turbo--collection" data-tables--turbo--collection-query-value="" id="table">
          <thead><tr><th class="type-date">Published on</th></tr></thead>
          <tbody><tr><td>#{value}</td></tr></tbody>
        </table>
      HTML
    end
  end

  context "with datetime" do
    let(:value) { I18n.l(collection.items.first&.created_at, format: :admin) }
    let(:content) { Proc.new { |row| row.datetime :created_at } }

    it "renders datetime column" do
      expect(table).to match_html(<<~HTML)
        <table data-controller="tables--turbo--collection" data-tables--turbo--collection-query-value="" id="table">
          <thead><tr><th class="type-datetime">Created at</th></tr></thead>
          <tbody><tr><td>#{value}</td></tr></tbody>
        </table>
      HTML
    end
  end

  context "with number" do
    let(:collection) { Katalyst::Tables::Collection::Base.new.apply(Banner.all) }
    let(:content) { Proc.new { |row| row.number :ordinal } }

    it "renders number column" do
      expect(table).to match_html(<<~HTML)
        <table data-controller="tables--turbo--collection" data-tables--turbo--collection-query-value="" id="table">
          <thead><tr><th class="type-number">Ordinal</th></tr></thead>
          <tbody><tr><td class="type-number">#{collection.items.first&.ordinal}</td></tr></tbody>
        </table>
      HTML
    end
  end

  context "with rich text" do
    let(:content) { Proc.new { |row| row.rich_text :content } }

    it "renders rich text column" do
      expect(table).to match_html(<<~HTML)
        <table data-controller="tables--turbo--collection" data-tables--turbo--collection-query-value="" id="table">
          <thead><tr><th class="type-text">Content</th></tr></thead>
          <tbody><tr>
            <td title="#{collection.items.first&.content&.to_plain_text}">
              #{collection.items.first&.content}
            </td>
          </tr></tbody>
        </table>
      HTML
    end
  end

  context "with link" do
    let(:content) { Proc.new { |row| row.link :name } }

    it "renders link column" do
      expect(table).to match_html(<<~HTML)
        <table data-controller="tables--turbo--collection" data-tables--turbo--collection-query-value="" id="table">
          <thead><tr><th class="type-link">Name</th></tr></thead>
          <tbody><tr>
            <td><a href="/admin/posts/#{collection.items.first&.id}">#{collection.items.first&.name}</a></td>
          </tr></tbody>
        </table>
      HTML
    end
  end

  context "with text" do
    let(:content) { Proc.new { |row| row.text :title } }

    it "renders text column" do
      expect(table).to match_html(<<~HTML)
        <table data-controller="tables--turbo--collection" data-tables--turbo--collection-query-value="" id="table">
          <thead><tr><th class="type-text">Title</th></tr></thead>
          <tbody><tr><td>#{collection.items.first&.title}</td></tr></tbody>
        </table>
      HTML
    end
  end
end
