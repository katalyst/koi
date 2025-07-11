# frozen_string_literal: true

require "active_support/core_ext/module/delegation"

class Dummy < Thor
  include Thor::Actions

  source_root File.expand_path("../../spec/templates", __dir__)

  def initialize(args = [], local_options = {}, config = {})
    super

    self.destination_root = File.expand_path("../../spec/dummy", __dir__)
  end

  def self.exit_on_failure?
    true
  end

  desc "install", "Generate dummy app"

  def install
    invoke :clobber
    invoke :bootstrap
    invoke :adopt
    invoke :scaffold
    puts "🎉 dummy app regenerated! 🎉"
  end

  desc "clobber", "Remove existing dummy app"

  def clobber
    run "rm -rf spec/dummy"
  end

  desc "bootstrap", "Regenerate dummy app using local koi-template"

  def bootstrap
    run "rm -f bin/rails" # rails new will check for this file and fail if it exists

    # Note: we have temporarily removed --skip-action-cable
    # https://github.com/hotwired/turbo-rails/issues/512
    run <<~SH
      cd spec && \
      rails new dummy \
        --database sqlite3 \
        --skip-action-cable \
        --skip-action-mailbox \
        --skip-action-mailer \
        --skip-bootsnap \
        --skip-ci \
        --skip-dev-gems \
        --skip-docker \
        --skip-git \
        --skip-jbuilder \
        --skip-kamal \
        --skip-keeps \
        --skip-solid \
        --skip-system-test \
        --skip-test \
        --skip-thruster \
        -a propshaft \
        -m #{template_base}/template.rb
    SH
    run "rm -rf spec/dummy/Gemfile*" # remove Gemfile* files
    run "git checkout HEAD -- bin/rails" # restore bin/rails
  end

  desc "adopt", "Re-configure dummy app to use local koi"

  def adopt
    gsub_file("config/boot.rb", %r{"../Gemfile"}, '"../../../Gemfile"')

    append_to_file("config/boot.rb", <<~RUBY)

      $LOAD_PATH.unshift File.expand_path("../../../lib", __dir__)
    RUBY

    # Remove Koi migrations that will be loaded directly from Koi
    run "rm -f spec/dummy/db/migrate/*.koi.rb"

    reset_database(migrate: true)

    # Update commit so we can more easily track changes
    run "cd spec/dummy && git add -A && git commit --amend -C HEAD"

    invoke :check
  end

  desc "scaffold", "Scaffold example module"

  def scaffold
    # Support local development of generators by clearing changes from previous run
    unless ENV["CI"]
      reset_to_head
      reset_database
    end

    inside("spec/dummy") do
      run <<~SH
        rails g koi:model Announcement name:string title:string content:rich_text published_on:date archived_at:datetime
        rails g koi:model Banner name:string image:attachment ordinal:integer status:integer
      SH
    end

    insert_into_file("app/models/announcement.rb",
                     "include Koi::Model::Archivable\n",
                     after: "ApplicationRecord\n")

    inside("spec/dummy") do
      run "rails db:migrate"

      run <<~SH
        rails g koi:admin Announcement
        rails g koi:admin Banner
      SH
    end

    Dir.glob(File.join(self.class.source_root, "**/*")).each do |file|
      copy_file(file[(self.class.source_root.size + 1)..], force: true) if File.file?(file)
    end

    # Load the schema
    # Rails writes the current db/schema.rb SHA1 to internal metadata on load but not on migrate.
    run "rails app:db:schema:load app:db:seed"

    format_generated_files
    invoke :check
  end

  desc "check", "Check dummy app migrations"

  def check
    SchemaChecker.new(self, "test").call
  end

  private

  def template_base
    base = Pathname.new(__dir__).join("../../../koi-template")

    return base if base.exist?

    "https://raw.githubusercontent.com/katalyst/koi-template/main"
  end

  def reset_to_head
    run "cd spec/dummy && git add -A && git reset --hard HEAD"
  end

  # Re-generate database using locally installed migrations
  def reset_database(migrate: false)
    if migrate
      run("rails app:db:drop app:db:create app:db:migrate app:db:schema:dump app:db:schema:load")
    else
      run("rails app:db:reset")
    end
  end

  # Format generated files
  def format_generated_files
    say_status :run, "Format generated files", :green
    run(<<~SH.gsub(/\s+/, " ").strip, verbose: false, abort_on_failure: false, capture: true)
      (cd spec/dummy && git status --porcelain -u) |
      grep '[.]rb'|
      awk '{print "spec/dummy/" $2}'|
      grep -v schema.rb|
      xargs rubocop -A
    SH
    run(<<~SH.gsub(/\s+/, " ").strip, verbose: false, abort_on_failure: true, capture: true)
      (cd spec/dummy && git status --porcelain -u) |
      grep '[.]erb'|
      awk '{print "spec/dummy/" $2}'|
      xargs erblint -a
    SH
  end
end

class SchemaChecker
  attr_reader :environment

  delegate_missing_to :@context

  def initialize(context, environment)
    @context     = context
    @environment = environment
  end

  # Check that the database actually contains the Koi migrations
  # This has been a persistent but intermittent issue. If the migrations are
  # not present in the schema_migrations table then tests will fail.
  def call
    if !migrations_ok?
      say_status :migrations, "Koi migrations are missing from #{environment}", :red
      run "sqlite3 #{database_path} 'select * from schema_migrations;'"
    elsif !schema_ok?
      say_status :migrations, "#{environment} checksum does not match schema", :red
      puts "  Database SHA1: '#{sqlite_sha1}'"
      puts "  Schema SHA1:   '#{schema_sha1}'"
      exit 1
    else
      say_status :migrations, "Database is ready to go (#{sqlite_sha1})", :green
    end
  end

  def migrations_ok?
    run(<<~SH.gsub(/\s+/, " ").strip, verbose: false, abort_on_failure: false)
      sqlite3 #{database_path} 'select * from schema_migrations;' |
      grep -q '^#{migration_version}'
    SH
  end

  def schema_ok?
    sqlite_sha1.eql?(schema_sha1)
  end

  def schema_sha1
    run(<<~SH.strip, verbose: false, capture: true)&.strip
      shasum #{schema_path} | awk '{print $1}'
    SH
  end

  def sqlite_sha1
    run(<<~SH.strip, verbose: false, abort_on_failure: false, capture: true)&.strip
      sqlite3 #{database_path} 'SELECT "ar_internal_metadata"."value" FROM "ar_internal_metadata" WHERE "ar_internal_metadata"."key" = "schema_sha1"  LIMIT 1';
    SH
  end

  private

  def database_path
    File.join(__dir__, "../../spec/dummy/db/#{environment}.sqlite3")
  end

  def schema_path
    File.join(__dir__, "../../spec/dummy/db/schema.rb")
  end

  def migration_version
    migrations = File.join(__dir__, "../../db/migrate/*.rb")
    File.basename(Dir.glob(migrations).first).split("_").first
  end
end
