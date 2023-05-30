# frozen_string_literal: true

require "rails_helper"

RSpec.describe UrlRewrite do
  subject(:url_rewrite) { create(:url_rewrite) }

  it { is_expected.to validate_presence_of(:from) }
  it { is_expected.to validate_presence_of(:to) }
  it { is_expected.to allow_values("/", "/path", "/path?query").for(:from) }
  it { is_expected.not_to allow_values("", "path", "path?query", "https://example.com").for(:from) }

  describe "#admin_search" do
    subject { described_class.admin_search(url_rewrite.from) }

    it { is_expected.to include(url_rewrite) }
  end

  describe "#redirect_path_for" do
    subject { described_class.redirect_path_for(url_rewrite.from) }

    it { is_expected.to eq(url_rewrite.to) }
  end
end
