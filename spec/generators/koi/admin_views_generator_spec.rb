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
      "app/views/admin/tests/_test.html+row.erb",
    )
  end

  it "creates the expected files" do
    output
    expect(Pathname.new(file("app/views/admin/tests/index.html.erb"))).to exist
    expect(Pathname.new(file("app/views/admin/tests/edit.html.erb"))).to exist
    expect(Pathname.new(file("app/views/admin/tests/show.html.erb"))).to exist
    expect(Pathname.new(file("app/views/admin/tests/new.html.erb"))).to exist
    expect(Pathname.new(file("app/views/admin/tests/_fields.html.erb"))).to exist
    expect(Pathname.new(file("app/views/admin/tests/_test.html+row.erb"))).to exist
  end
end
