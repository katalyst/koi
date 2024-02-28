# frozen_string_literal: true

require "rails_helper"

RSpec.describe Koi::DateHelper do
  describe "#days_ago_in_words" do
    it "renders today" do
      expect(helper.days_ago_in_words(Date.current)).to eq("today")
    end

    it "renders tomorrow" do
      expect(helper.days_ago_in_words(Date.tomorrow)).to eq("tomorrow")
    end

    it "renders two days from now" do
      expect(helper.days_ago_in_words(Date.current + 2.days)).to eq("2 days from now")
    end

    it "renders two days ago" do
      expect(helper.days_ago_in_words(Date.current - 2.days)).to eq("2 days ago")
    end

    it "returns nil" do
      expect(helper.days_ago_in_words(Date.current - 6.days)).to be_nil
    end
  end
end
