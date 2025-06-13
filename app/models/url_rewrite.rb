# frozen_string_literal: true

class UrlRewrite < ApplicationRecord
  enum :status_code, [303, 307, 308].index_by(&:itself)

  attribute :status_code, :integer, default: 303

  validates :from, :to, presence: true
  validates :from, format: { with: %r{\A/.*\z}, message: "should start with /" } # rubocop:disable Rails/I18nLocaleTexts

  scope :active, -> { where(active: true) }
  scope :alphabetical, -> { order(from: :asc) }

  def to_s
    "#{from} -> #{to}"
  end

  scope :admin_search, ->(query) do
    where(arel_table[:from].matches("%#{query}%").or(arel_table[:to].matches("%#{query}%")))
  end

  def title
    from.delete_prefix("/")
  end
end
