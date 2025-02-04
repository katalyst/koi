# frozen_string_literal: true

require "rails_helper"

RSpec.describe WellKnown do
  subject { create(:well_known) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:purpose) }
  it { is_expected.to allow_values("text/plain", "application/json").for(:content_type) }
  it { is_expected.to allow_values(:text, :json).for(:content_type) }
end
