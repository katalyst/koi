# frozen_string_literal: true

require "rails_helper"

require "generators/koi/active_record/active_record_generator"

RSpec.describe Koi::ActiveRecordGenerator do
  subject(:output) do
    gen = generator(%w(resource title:string slug:string content:rich_text))
    Ammeter::OutputCapturer.capture(:stdout) { gen.invoke_all }
  end

  it "runs the expected creation steps" do
    expect(output.lines.grep(/create/).map { |l| l.split.last }).to contain_exactly(
      "app/models/resource.rb",
      %r{db/migrate/\d+_create_resources.rb},
      "spec/factories/resources.rb",
      "spec/models/resource_spec.rb",
    )
  end

  it "creates the expected files" do
    output
    expect(Pathname.new(file("app/models/resource.rb"))).to exist
    expect(Pathname.new(migration_file("db/migrate/create_resources.rb"))).to exist
    expect(Pathname.new(file("spec/models/resource_spec.rb"))).to exist
  end
end
