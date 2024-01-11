# frozen_string_literal: true

require "rails_helper"

describe Koi::SummaryListComponent do
  subject(:component) { described_class.new(model:) }

  let(:model) { create(:post) }

  it "renders list" do
    render_inline(component)
    expect(page).to have_css("dl.summary-list")
  end
end
