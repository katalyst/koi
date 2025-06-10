# frozen_string_literal: true

require "rails_helper"

require "generators/koi/admin_views/admin_views_generator"

RSpec.describe Koi::AdminViewsGenerator do
  subject(:output) do
    gen = generator(%w(comment))
    Ammeter::OutputCapturer.capture(:stdout) { gen.invoke_all }
  end

  it "generates the expected output" do
    expect(output.lines.grep(/create/).map { |l| l.split.last }).to contain_exactly(
      "app/views/admin/comments",
      "app/views/admin/comments/_form.html.erb",
      "app/views/admin/comments/edit.html.erb",
      "app/views/admin/comments/index.html.erb",
      "app/views/admin/comments/new.html.erb",
      "app/views/admin/comments/show.html.erb",
    )
  end

  it "creates the expected files" do
    output
    expect(Pathname.new(file("app/views/admin/comments/index.html.erb"))).to exist
    expect(Pathname.new(file("app/views/admin/comments/edit.html.erb"))).to exist
    expect(Pathname.new(file("app/views/admin/comments/show.html.erb"))).to exist
    expect(Pathname.new(file("app/views/admin/comments/new.html.erb"))).to exist
    expect(Pathname.new(file("app/views/admin/comments/_form.html.erb"))).to exist
  end

  describe "with explicit attributes" do
    before do
      gen = generator(%w(example
                         title:string
                         description:rich_text
                         ordinal:integer
                         archived_at:datetime
                         post:belongs_to))
      Ammeter::OutputCapturer.capture(:stdout) { gen.invoke_all }
    end

    describe "views/admin/examples/show.html.erb" do
      subject { file("app/views/admin/examples/show.html.erb") }

      it { is_expected.to contain "<%= summary_table_with(model: example) do |row| %>" }
      it { is_expected.to contain "<% row.text :title %>" }
      it { is_expected.to contain "<% row.rich_text :description %>" }
      it { is_expected.to contain "<% row.datetime :archived_at %>" }
      it { is_expected.to contain "<% row.link :post %>" }
    end

    describe "views/admin/examples/index.html.erb" do
      subject { file("app/views/admin/examples/index.html.erb") }

      it { is_expected.to contain "<%= table_with(collection:) do |row, example| %>" }
      it { is_expected.to contain "<% row.ordinal unless collection.filtered? %>" }
      it { is_expected.to contain "<% row.link :title %>" }
      it { is_expected.to contain "<% row.datetime :archived_at %>" }
    end
  end

  context "with posts model introspection" do
    subject(:output) do
      gen = generator(%w(post))
      Ammeter::OutputCapturer.capture(:stdout) { gen.invoke_all }
    end

    before { output }

    it "generates views for existing models" do
      expect(output.lines.grep(/create/).map { |l| l.split.last }).to contain_exactly(
        "app/views/admin/posts",
        "app/views/admin/posts/index.html.erb",
        "app/views/admin/posts/edit.html.erb",
        "app/views/admin/posts/show.html.erb",
        "app/views/admin/posts/new.html.erb",
        "app/views/admin/posts/_form.html.erb",
      )
    end

    describe "views/admin/posts/show.html.erb" do
      subject { file("app/views/admin/posts/show.html.erb") }

      it { is_expected.to contain "<%= summary_table_with(model: post) do |row| %>" }
      it { is_expected.to contain "<% row.text :name %>" }
      it { is_expected.to contain "<% row.text :title %>" }
      it { is_expected.to contain "<% row.rich_text :content %>" }
      it { is_expected.to contain "<% row.boolean :active %>" }
      it { is_expected.to contain "<% row.date :published_on %>" }
    end

    describe "views/admin/posts/index.html.erb" do
      subject { file("app/views/admin/posts/index.html.erb") }

      it { is_expected.to contain "<% row.link :name %>" } # First attribute is always a link
      it { is_expected.to contain "<% row.text :title %>" }
      it { is_expected.to contain "<% row.boolean :active %>" }
      it { is_expected.to contain "<% row.date :published_on %>" }
    end
  end

  context "with banners model introspection" do
    subject(:output) do
      gen = generator(%w(banner))
      Ammeter::OutputCapturer.capture(:stdout) { gen.invoke_all }
    end

    before { output }

    it "generates views for existing models" do
      expect(output.lines.grep(/create/).map { |l| l.split.last }).to contain_exactly(
        "app/views/admin/banners",
        "app/views/admin/banners/index.html.erb",
        "app/views/admin/banners/edit.html.erb",
        "app/views/admin/banners/show.html.erb",
        "app/views/admin/banners/new.html.erb",
        "app/views/admin/banners/_form.html.erb",
      )
    end

    describe "views/admin/banners/index.html.erb" do
      subject { file("app/views/admin/banners/index.html.erb") }

      it { is_expected.to contain "<% row.ordinal unless collection.filtered? %>" }
      it { is_expected.to contain "<% row.link :name %>" }
      it { is_expected.to contain "<% row.enum :status %>" }
      it { is_expected.not_to contain /image/ }
    end

    describe "views/admin/banners/show.html.erb" do
      subject { file("app/views/admin/banners/show.html.erb") }

      it { is_expected.not_to contain /ordinal/ }
      it { is_expected.to contain "<% row.text :name %>" }
      it { is_expected.to contain "<% row.enum :status %>" }
      it { is_expected.to contain "<% row.attachment :image %>" }
    end
  end
end
