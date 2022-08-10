class NavigationMenu < ApplicationRecord
  before_destroy :unset_versions

  belongs_to :latest_version, inverse_of: :parent, class_name: "NavigationMenu::Version", optional: true, autosave: true
  belongs_to :current_version, inverse_of: :parent, class_name: "NavigationMenu::Version", optional: true, autosave: true

  has_many :navigation_versions, foreign_key: :parent_id, inverse_of: :parent, validate: true,
           dependent: :delete_all, class_name: "NavigationMenu::Version"
  has_many :navigation_links, validate: true, dependent: :delete_all, autosave: true

  validates :title, :slug, presence: true
  validates :slug, uniqueness: true

  before_validation :parameterize_slug

  # @override
  #
  # Overrides the default to_param, enables use of ModelName.find_by(slug: params[:slug])
  def to_param
    slug.presence || super
  end

  # Builds a nested menu structure for use in views.
  def menu
    navigation_links.reduce(Navigation::OrdinalTree::Builder.new) do |builder, nav|
      builder.add(nav)
    end.tree
  end

  def visible_items?
    navigation_links&.select(&:visible?).present?
  end

  def state
    if current_version_id && current_version_id == latest_version_id
      :published
    else
      :draft
    end
  end

  def publish!
    update!(current_version: self.latest_version)
  end

  def revert!
    update!(latest_version: self.current_version)
  end

  def navigation_links_attributes=(attributes)
    next_version.items = attributes
  end

  delegate :items, :navigation_links, :tree, to: :current_version, prefix: :current, allow_nil: true
  delegate :items, :navigation_links, :tree, to: :latest_version, prefix: :latest, allow_nil: true

  private

  def unset_versions
    update(latest_version: nil, current_version: nil)
  end

  def next_version
    if self.latest_version.nil?
      build_latest_version
    elsif self.latest_version.persisted?
      self.latest_version = self.latest_version.dup
    else
      self.latest_version
    end
  end

  def parameterize_slug
    self.slug = slug.parameterize if slug.present?
  end

  class Item
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :id, :integer
    attribute :index, :integer
    attribute :depth, :integer, default: 0

    def as_json
      attributes.slice("id", "depth").as_json
    end
  end

  class ItemsType < ActiveRecord::Type::Json
    def serialize(value)
      super(value.as_json)
    end

    def deserialize(value)
      case value
      when nil
        nil
      when String
        deserialize(super)
      when Hash
        value.map do |index, attributes|
          Item.new(index: index, **attributes)
        end.select(&:id).sort_by(&:index)
      when Array
        value.map.with_index do |attributes, index|
          Item.new(index: index, **attributes)
        end.select(&:id).sort_by(&:index)
      end
    end
  end

  class Version < ApplicationRecord

    belongs_to :parent, inverse_of: :navigation_versions, class_name: "NavigationMenu"

    attribute :items, ItemsType.new, default: []

    def navigation_links
      # TODO(sfn) database join and ordering
      links = parent.navigation_links.where(id: items.map(&:id)).index_by(&:id)

      items.map do |item|
        link       = links[item.id]
        link.index = item.index
        link.depth = item.depth
        link
      end
    end

    def tree
      navigation_links.reduce(Navigation::OrdinalTree::Builder.new) do |builder, nav|
        builder.add(nav)
      end.tree
    end
  end
end
