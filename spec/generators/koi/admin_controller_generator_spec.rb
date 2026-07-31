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

  # Introspected attachments follow their reflection's macro: a has_one
  # submits a scalar signed id, a has_many an array (the attachment
  # field's `name[]` inputs), so the permit shapes must differ.
  context "with a model with attachments" do
    subject(:output) do
      gen = generator(%w(banner))
      Ammeter::OutputCapturer.capture(:stdout) { gen.invoke_all }
    end

    let(:controller) { File.read(file("app/controllers/admin/banners_controller.rb")) }

    it "permits a has_many attachment as an array" do
      output
      expect(controller).to include("gallery: []")
    end

    it "permits a has_one attachment as a scalar" do
      output
      expect(controller).to include(":image")
    end

    it "does not permit the has_one attachment as an array" do
      output
      expect(controller).not_to include("image: []")
    end
  end
end
