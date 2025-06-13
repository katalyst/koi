# frozen_string_literal: true

require "rails/generators/active_record/model/model_generator"

module Koi
  class ModelGenerator < ActiveRecord::Generators::ModelGenerator
    source_root ActiveRecord::Generators::ModelGenerator.source_root

    def admin_search
      "PgSearch::Model".safe_constantize ? pg_search : sql_search
    end

    def ordinal_scope
      return unless attributes.any? { |attr| attr.name == "ordinal" }

      insert_into_file "app/models/#{file_path}.rb", before: /end\Z/ do
        <<~RUBY
          default_scope -> { order(ordinal: :asc) }
        RUBY
      end
    end

    private

    def pg_search
      insert_into_file "app/models/#{file_path}.rb", after: "class #{class_name} < ApplicationRecord\n" do
        <<~RUBY
          include PgSearch::Model
        RUBY
      end

      insert_into_file "app/models/#{file_path}.rb", before: /end\Z/ do
        <<~RUBY
          pg_search_scope :admin_search, against: %i[#{search_fields.join(' ')}], using: { tsearch: { prefix: true } }
        RUBY
      end
    end

    def sql_search
      insert_into_file "app/models/#{file_path}.rb", before: /end\Z/ do
        clause = search_fields.map { |f| "#{f} LIKE :query" }.join(" OR ")
        <<~RUBY
          scope :admin_search, ->(query) do
            where("#{clause}", query: "%\#{query}%")
          end
        RUBY
      end
    end

    def search_fields
      attributes.select { |attr| attr.type == :string }.map(&:name)
    end
  end
end
