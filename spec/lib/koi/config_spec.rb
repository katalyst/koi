# frozen_string_literal: true

require "rails_helper"

RSpec.describe Koi::Config do
  subject(:config) { described_class.new }

  describe "#load" do
    let(:path) { Rails.root.join("config/koi.yml") }

    after { FileUtils.rm_f(path) }

    context "when config/koi.yml is absent" do
      # The dummy app ships no koi.yml, so config_for genuinely can't find one.
      it "leaves the config at its defaults and does not raise", :aggregate_failures do
        expect { config.load(Rails.application) }.not_to raise_error
        expect(config.admin_name).to eq("Koi")
      end
    end

    context "when config/koi.yml is present" do
      it "merges shared + environment and evaluates ERB", :aggregate_failures do
        ENV["KOI_SPEC_SITE_NAME"] = "Example Site"
        File.write(path, <<~YAML)
          shared:
            admin_name: Shared Admin
          test:
            site_name: <%= ENV["KOI_SPEC_SITE_NAME"] %>
        YAML

        config.load(Rails.application)

        expect(config.admin_name).to eq("Shared Admin")
        expect(config.site_name).to eq("Example Site")
      ensure
        ENV.delete("KOI_SPEC_SITE_NAME")
      end
    end

    context "when config/koi.yml names an unknown setting" do
      it "raises rather than silently dropping it" do
        File.write(path, "test:\n  nonsense: true\n")

        expect { config.load(Rails.application) }
          .to raise_error(ArgumentError, /Unknown Koi config setting: nonsense/)
      end
    end

    context "when config/koi.yml is malformed" do
      # Only a missing file is recovered from; a broken file must fail boot.
      it "lets the error surface rather than silently ignoring it" do
        File.write(path, "test:\n  admin_name: {bad\n")

        expect { config.load(Rails.application) }.to raise_error(/YAML syntax error/)
      end
    end
  end

  describe "assigning an unknown setting directly" do
    it "raises a helpful error rather than a bare NoMethodError" do
      expect { config.nonsense = true }
        .to raise_error(ArgumentError, /Unknown Koi config setting: nonsense/)
    end
  end
end
