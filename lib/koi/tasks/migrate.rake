require 'koi/migration/active_storage'

namespace :koi do
  namespace :migrate do
    desc "Migrate to active storage"
    task active_storage: :environment do
      dry_run = ActiveModel::Type::Boolean.new.cast(ENV["DRY_RUN"] || false)
      migrator = Koi::Migration::ActiveStorage.new
      migrator.migrate_models(migrations: ENV["MODELS"].split(" "), dry_run: dry_run) if ENV["MODELS"]
      migrator.migrate_attributes(migrations: ENV["ATTRIBUTES"].split(" "), dry_run: dry_run) if ENV["ATTRIBUTES"]
    end
  end
end
