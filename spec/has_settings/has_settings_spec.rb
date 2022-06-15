# frozen_string_literal: true

require "rails_helper"

class HasSettingsImpl
  include ActiveModel::Model
  include ActiveModel::Attributes
  extend ActiveModel::Callbacks

  define_model_callbacks :create, :update, :save, :destroy

  include HasSettings

  has_settings
end

RSpec.describe HasSettings do
  subject { model }

  let(:model) { HasSettingsImpl.new }

  describe "#setting" do
    it { expect(HasSettingsImpl.setting("test1", "1", field_type: "boolean")).to eq(true) }
    it { expect(HasSettingsImpl.setting("test2", "0", field_type: "boolean")).to eq(false) }
    it { expect(HasSettingsImpl.setting("test3", "value", field_type: "text")).to eq("value") }
  end
end
