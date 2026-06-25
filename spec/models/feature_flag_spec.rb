# frozen_string_literal: true

require "rails_helper"

RSpec.describe FeatureFlag do
  let(:key) { "my_feature" }

  describe "validations" do
    it "requires a key", :aggregate_failures do
      flag = described_class.build(key: nil)

      expect(flag).not_to be_valid
      expect(flag.errors[:key]).to include("can't be blank")
    end

    it "is valid with a key" do
      expect(described_class.build(key:)).to be_valid
    end

    it "allows letters, numbers and underscores" do
      expect(described_class.build(key: "My_Feature_2")).to be_valid
    end

    it "rejects keys with characters the router would mangle" do
      flag = described_class.build(key: "search.v2")

      expect(flag).not_to be_valid
    end
  end

  describe ".build" do
    it "wraps the given key without registering it", :aggregate_failures do
      flag = described_class.build(key:)

      expect(flag.key).to eq(key)
      expect(Flipper.exist?(key)).to be(false)
    end

    it "builds a blank flag with no arguments" do
      expect(described_class.build.key).to be_nil
    end
  end

  describe ".find" do
    it "returns the wrapped feature" do
      Flipper.add(key)

      expect(described_class.find(key).key).to eq(key)
    end

    it "raises when the feature does not exist" do
      expect { described_class.find("missing") }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe ".all" do
    it "returns every feature wrapped and ordered by key", :aggregate_failures do
      Flipper.add("beta")
      Flipper.add("alpha")

      expect(described_class.all).to all(be_a(described_class))
      expect(described_class.all.map(&:key)).to eq(%w[alpha beta])
    end
  end

  describe "#save" do
    it "registers a valid feature", :aggregate_failures do
      flag = described_class.build(key: "new_feature")

      expect(flag.save).to be(true)
      expect(Flipper.exist?("new_feature")).to be(true)
    end

    it "is idempotent for an existing key" do
      Flipper.add(key)

      expect(described_class.build(key:).save).to be(true)
    end

    it "does not register an invalid feature", :aggregate_failures do
      flag = described_class.build(key: "")

      expect(flag.save).to be(false)
      expect(flag.errors[:key]).to include("can't be blank")
      expect(Flipper.features).to be_empty
    end
  end

  describe "#update" do
    subject(:flag) { described_class.find(key) }

    before { Flipper.add(key) }

    context "with state 'on'" do
      it "fully enables the feature" do
        flag.update(state: "on")

        expect(Flipper.feature(key).state).to eq(:on)
      end
    end

    context "with state 'off'" do
      before { Flipper.enable(key) }

      it "fully disables the feature" do
        flag.update(state: "off")

        expect(Flipper.feature(key).state).to eq(:off)
      end
    end

    context "with conditional rules" do
      let(:attributes) do
        { state: "conditional", groups: ["admins"], actors: "Admin::User;1", percentage_of_actors: "25", percentage_of_time: "0" }
      end

      it "applies each gate", :aggregate_failures do
        flag.update(attributes)

        feature = Flipper.feature(key)
        expect(feature.groups_value).to include("admins")
        expect(feature.actors_value).to include("Admin::User;1")
        expect(feature.percentage_of_actors_value).to eq(25)
      end

      it "ignores a zero percentage" do
        flag.update(attributes)

        expect(Flipper.feature(key).percentage_of_time_value).to eq(0)
      end

      it "parses multiple actors from whitespace and commas" do
        flag.update(state: "conditional", actors: "Admin::User;1, Admin::User;2\nAdmin::User;3")

        expect(Flipper.feature(key).actors_value).to contain_exactly("Admin::User;1", "Admin::User;2", "Admin::User;3")
      end

      it "switches a fully-on feature to conditional" do
        Flipper.enable(key)

        expect { flag.update(attributes) }
          .to change { Flipper.feature(key).state }.from(:on).to(:conditional)
      end
    end
  end

  describe "#destroy" do
    it "removes the feature from Flipper" do
      Flipper.add(key)

      expect { described_class.find(key).destroy }
        .to change { Flipper.exist?(key) }.from(true).to(false)
    end
  end

  describe "#persisted?" do
    it "is true for a registered feature" do
      Flipper.add(key)

      expect(described_class.find(key)).to be_persisted
    end

    it "is false for an unsaved build" do
      expect(described_class.build(key:)).not_to be_persisted
    end
  end

  describe "gate readers" do
    subject(:flag) { described_class.find(key) }

    before { Flipper.add(key) }

    it "exposes enabled groups as names" do
      Flipper.enable_group(key, :admins)

      expect(flag.groups).to eq(["admins"])
    end

    it "exposes enabled actors as a newline-separated list" do
      Flipper.enable_actor(key, Flipper::Actor.new("Admin::User;1"))
      Flipper.enable_actor(key, Flipper::Actor.new("Admin::User;2"))

      expect(flag.actors).to eq("Admin::User;1\nAdmin::User;2")
    end

    it "exposes the percentage of actors" do
      Flipper.enable_percentage_of_actors(key, 40)

      expect(flag.percentage_of_actors).to eq(40)
    end
  end

  describe "#to_param" do
    it "is the key" do
      expect(described_class.build(key:).to_param).to eq(key)
    end
  end
end
