# frozen_string_literal: true

class AddHiddenToLegacyPages < ActiveRecord::Migration[7.0]
  # rubocop:disable Rails/SkipsModelValidations
  def up
    add_column :legacy_pages, :hidden, :boolean, default: false, nil: false

    pages = LegacyPage.arel_table

    resources = Arel::Table.new("nav_items", klass: nil).alias("resources")
    on_resource = resources.create_on(resources[:navigable_type].eq("LegacyPage")
                                                                .and(resources[:navigable_id].eq(pages[:id])))

    # pages that don't have a resource are hidden
    LegacyPage.joins(pages.create_join(resources, on_resource, Arel::Nodes::OuterJoin))
      .where(resources[:id].eq(nil)).update_all(hidden: true)

    ancestors = Arel::Table.new("nav_items", klass: nil).alias("ancestors")
    on_ancestors = ancestors.create_on(ancestors[:lft].lteq(resources[:lft])
                                                      .and(ancestors[:rgt].gteq(resources[:rgt]))
                                                      .and(ancestors[:is_hidden].eq(true)))

    # pages whose resource is hidden are hidden
    LegacyPage.joins(pages.create_join(resources, on_resource))
      .joins(pages.create_join(ancestors, on_ancestors))
      .update_all(hidden: true)
  end
  # rubocop:enable Rails/SkipsModelValidations

  def down
    remove_column :legacy_pages, :hidden, :boolean, default: false, nil: false
  end
end
