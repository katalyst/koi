# frozen_string_literal: true

require "rails_helper"

require "generators/koi/admin_controller/admin_controller_generator"

RSpec.describe Koi::AdminControllerGenerator do
  subject(:output) do
    gen = generator(%w(test title:string slug:string content:rich_text))
    Ammeter::OutputCapturer.capture(:stdout) { gen.invoke_all }
  end

  it "runs the expected creation steps" do
    expect(output.lines.grep(/create/).grep(/controller/).map { |l| l.split.last }).to contain_exactly(
      "app/controllers/admin/tests_controller.rb",
      "spec/requests/admin/tests_controller_spec.rb",
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
    expect(Pathname.new(file("app/controllers/admin/tests_controller.rb"))).to exist
    expect(Pathname.new(file("spec/requests/admin/tests_controller_spec.rb"))).to exist
  end
end
