# frozen_string_literal: true

if ActiveRecord::Base.connection.tables.include?("translations")
  require "i18n/backend/active_record"
  I18n.backend = I18n::Backend::ActiveRecord.new

  I18n::Backend::ActiveRecord.include I18n::Backend::Cache
  I18n.cache_store = ActiveSupport::Cache.lookup_store(:memory_store)

  I18n::Backend::Chain.include I18n::Backend::ActiveRecord::Missing
  I18n.backend = I18n::Backend::Chain.new(I18n::Backend::ActiveRecord.new, I18n::Backend::Simple.new)
end
