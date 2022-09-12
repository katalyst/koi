# frozen_string_literal: true

class LegacyPage < ApplicationRecord
  has_crud paginate: false, navigation: true,
           settings: true

  validates_presence_of :title

  def titleize
    title
  end

  def to_s
    title
  end

  crud.config do
    actions only: %i[index show]
    hide false
    title collection: "Pages"
    config :admin do
      actions except: [:new]
      index   fields: %i[id title]
      form    except: [:type]
    end
  end

  # overriding has_navigation methods to work with koi page route namespacing
  def self.get_new_admin_url(options = {})
    Koi::Engine.routes.url_helpers.new_legacy_page_path(options)
  end

  def get_edit_admin_url(options = {})
    Koi::Engine.routes.url_helpers.edit_legacy_page_path(self, options)
  end

  def self.settings_prefix
    "page"
  end

  def settings_prefix
    "#{id}.page"
  end
end
