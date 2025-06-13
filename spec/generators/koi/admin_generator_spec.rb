# frozen_string_literal: true

require "rails_helper"

require "generators/koi/admin/admin_generator"

RSpec.describe Koi::AdminGenerator do
  subject(:output) do
    gen = generator(%w(resource title:text content:rich_text))
    Ammeter::OutputCapturer.capture(:stdout) { gen.invoke_all }
  end

  it "invokes the expected generators" do
    expect(output.lines.grep(/invoke/).map { |line| line.split.last }).to contain_exactly(
      "admin_controller",
      "admin_route",
      "admin_views",
    )
  end
end
