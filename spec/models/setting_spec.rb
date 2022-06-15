# frozen_string_literal: true

require "rails_helper"

RSpec.describe Setting, type: :model do
  subject(:setting) { build :setting }

  it { is_expected.to validate_presence_of(:locale) }
  it { is_expected.to validate_presence_of(:label) }
  it { is_expected.to validate_presence_of(:key) }
  it { is_expected.to validate_presence_of(:field_type) }
  it { is_expected.to validate_presence_of(:prefix) }
end
