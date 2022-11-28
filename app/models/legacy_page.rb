# frozen_string_literal: true

class LegacyPage < ApplicationRecord
  has_crud paginate: false, settings: true

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

  def self.settings_prefix
    "page"
  end

  def settings_prefix
    "#{id}.page"
  end
end
