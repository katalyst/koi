# frozen_string_literal: true

require "rails_helper"

require "generators/koi/admin_views/admin_views_generator"

RSpec.describe Koi::AdminViewsGenerator do
  subject(:output) do
    gen = generator(%w(test))
    Ammeter::OutputCapturer.capture(:stdout) { gen.invoke_all }
  end

  it "generates the expected output" do
    expect(output.lines.map { |l| l.split.last }).to contain_exactly(
      "app/views/admin/tests",
      "app/views/admin/tests/index.html.erb",
      "app/views/admin/tests/edit.html.erb",
      "app/views/admin/tests/show.html.erb",
      "app/views/admin/tests/new.html.erb",
      "app/views/admin/tests/_fields.html.erb",
    )
  end

  it "creates the expected files" do
    output
    expect(Pathname.new(file("app/views/admin/tests/index.html.erb"))).to exist
    expect(Pathname.new(file("app/views/admin/tests/edit.html.erb"))).to exist
    expect(Pathname.new(file("app/views/admin/tests/show.html.erb"))).to exist
    expect(Pathname.new(file("app/views/admin/tests/new.html.erb"))).to exist
    expect(Pathname.new(file("app/views/admin/tests/_fields.html.erb"))).to exist
  end

  describe "views/admin/tests/show.html.erb" do
    subject { file("app/views/admin/tests/show.html.erb") }

    before do
      gen = generator(%w(test title:string description:rich_text ordinal:integer archived_at:datetime active:boolean))
      Ammeter::OutputCapturer.capture(:stdout) { gen.invoke_all }
    end

    it { is_expected.to contain "<h2>Summary</h2>" }
    it { is_expected.to contain "<%= summary_table_with(model: test) do |row| %>" }
    it { is_expected.to contain "<% row.link :title %>" }
    it { is_expected.to contain "<% row.rich_text :description %>" }
    it { is_expected.to contain "<% row.number :ordinal %>" }
    it { is_expected.to contain "<% row.datetime :archived_at %>" }
    it { is_expected.to contain "<% row.boolean :active %>" }
  end
end
