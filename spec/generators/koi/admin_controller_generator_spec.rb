# frozen_string_literal: true

require "rails_helper"

require "generators/koi/admin_controller/admin_controller_generator"

RSpec.describe Koi::AdminControllerGenerator do
  subject(:output) do
    gen = generator(%w(announcement))
    Ammeter::OutputCapturer.capture(:stdout) { gen.invoke_all }
  end

  it "runs the expected creation steps" do
    expect(output.lines.grep(/create/).grep(/controller/).map { |l| l.split.last }).to contain_exactly(
      "app/controllers/admin/announcements_controller.rb",
      "spec/requests/admin/announcements_controller_spec.rb",
    )
  end

  it "invokes generators" do
    expect(output.lines.grep(/invoke/).map { |l| l.split.last }).to contain_exactly(
      "admin_route",
      "admin_views",
    )
  end

  it "creates the expected files" do
    output
    expect(Pathname.new(file("app/controllers/admin/announcements_controller.rb"))).to exist
    expect(Pathname.new(file("spec/requests/admin/announcements_controller_spec.rb"))).to exist
  end
end
