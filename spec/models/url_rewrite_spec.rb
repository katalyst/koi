# frozen_string_literal: true

require "rails_helper"

RSpec.describe UrlRewrite do
  subject(:url_rewrite) { build(:url_rewrite) }

  it { is_expected.to validate_presence_of(:from) }
  it { is_expected.to validate_presence_of(:to) }
  it { is_expected.to allow_values("/", "/path", "/path?query").for(:from) }
  it { is_expected.not_to allow_values("", "path", "path?query", "https://example.com").for(:from) }
  it { is_expected.not_to allow_values("").for(:to) }

  describe "#strip_whitespace" do
    it "strips whitespace from to and from" do
      rewrite = build(:url_rewrite, from: " /path", to: " /to").tap(&:validate)
      expect(rewrite).to have_attributes(from: "/path", to: "/to")
    end
  end

  describe "#admin_search" do
    subject { described_class.admin_search(url_rewrite.from) }

    let(:url_rewrite) { create(:url_rewrite) }

    it { is_expected.to include(url_rewrite) }
  end
end
