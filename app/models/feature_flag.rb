# frozen_string_literal: true

# Presents a Flipper feature for the admin UI. Wrapping Flipper::Feature in an
# ActiveModel-compatible object lets it flow through Koi's table, form, and
# routing helpers.
class FeatureFlag
  include ActiveModel::Model
  include ActiveModel::Attributes

  def self.all
    Flipper.features.sort_by(&:key).map { |feature| new(feature:) }
  end

  def self.find(key)
    raise ActiveRecord::RecordNotFound, "Couldn't find feature #{key.inspect}" unless Flipper.exist?(key)

    new(key:)
  end

  def self.build(key: nil)
    new(key:)
  end

  attribute :key, :string

  validates :key, presence: true
  validates :key, format: { with: /\A[a-z0-9_]+\z/i }, allow_blank: true

  # @return [Flipper::Feature]
  attr_reader :feature

  delegate_missing_to :feature

  # @param [Flipper::Feature] feature
  def initialize(feature: nil, **)
    super(**)

    if feature
      self.key = feature.key
      @feature = feature
    else
      @feature = Flipper.feature(key.to_s)
    end
  end

  # Validate and register the feature. Returns false (leaving errors populated)
  # when invalid. Adding is idempotent, so re-saving an existing key is a no-op.
  def save # rubocop:disable Naming/PredicateMethod
    return false unless valid?

    Flipper.add(key)
    true
  end

  # Apply the desired availability from the form: fully on, fully off, or a set
  # of conditional rules. Clear the gates before applying rules so a previously
  # set boolean gate can't mask them — Flipper reads a feature as fully on
  # whenever its boolean gate is set, and there's no way to disable only that
  # gate.
  def update(attributes) # rubocop:disable Naming/PredicateMethod
    case attributes[:state]
    when "on"  then enable
    when "off" then disable
    else            configure(attributes)
    end

    true
  end

  # Remove the feature from Flipper entirely.
  def destroy
    Flipper.remove(key)
  end

  # Enabled groups as names, for display and form pre-fill.
  def groups
    groups_value.to_a
  end

  def percentage_of_actors
    percentage_of_actors_value
  end

  def percentage_of_time
    percentage_of_time_value
  end

  # Enabled actors as a newline-separated list of flipper ids, for editing.
  def actors
    actors_value.to_a.join("\n")
  end

  # A wrapped feature is backed by a registered Flipper feature, so it counts as
  # persisted. Lets Koi helpers (e.g. link_to_delete) treat it like a record.
  def persisted?
    key.present? && Flipper.exist?(key)
  end

  def to_param
    key
  end

  def to_s
    key
  end

  private

  def configure(attributes)
    clear

    Array(attributes[:groups]).compact_blank.each { |name| enable_group(name) }
    parse_actors(attributes[:actors]).each { |id| enable_actor(Flipper::Actor.new(id)) }

    apply_percentage(:enable_percentage_of_actors, attributes[:percentage_of_actors])
    apply_percentage(:enable_percentage_of_time, attributes[:percentage_of_time])
  end

  def apply_percentage(method, value)
    percentage = value.to_i

    public_send(method, percentage) if percentage.positive?
  end

  def parse_actors(value)
    value.to_s.split(/[\s,]+/)
  end
end
