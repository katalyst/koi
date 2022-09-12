# frozen_string_literal: true

# rubocop:disable Rails/SkipsModelValidations
class RenamePagesToLegacyPages < ActiveRecord::Migration[7.0]
  def rename_slug_type(from, to)
    update(<<~SQL, nil, [from, to])
      UPDATE friendly_id_slugs SET sluggable_type = $2 WHERE sluggable_type = $1;
    SQL
  end

  def rename_navigable_type(from, to)
    update(<<~SQL, nil, [from, to])
      UPDATE nav_items SET navigable_type = $2 WHERE navigable_type = $1;
    SQL
  end

  def up
    rename_table :pages, :legacy_pages
    rename_navigable_type "Page", "LegacyPage"
    rename_slug_type "Page", "LegacyPage"
  end

  def down
    rename_slug_type "LegacyPage", "Page"
    rename_navigable_type "LegacyPage", "Page"
    rename_table :legacy_pages, :pages
  end
end
# rubocop:enable Rails/SkipsModelValidations
