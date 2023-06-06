# frozen_string_literal: true

class Dummy < Thor
  include Thor::Actions

  def self.exit_on_failure?
    true
  end

  desc "install", "Generate dummy app"

  def install
    invoke :clobber
    invoke :generate
    invoke :template
    puts "🎉 dummy app regenerated! 🎉"
  end

  desc "clobber", "Remove existing dummy app"

  def clobber
    run "rm -rf spec/dummy"
  end

  desc "generate", "Regenerate dummy app using local koi-template"

  def generate
    run "rm -f bin/rails" # rails new will check for this file and fail if it exists
    run <<~SH
      cd spec && \
      rails new dummy \
        --skip-action-cable \
        --skip-action-mailer \
        --skip-action-mailbox \
        --skip-active-job \
        --skip-bootsnap \
        --skip-dev-gems \
        --skip-jbuilder \
        --skip-system-test \
        --skip-test \
        --skip-git \
        --skip-keeps \
        -a sprockets \
        -m #{template_base}/template.rb
    SH
    run "rm -rf spec/dummy/Gemfile*" # remove Gemfile* files
    run "git checkout HEAD -- bin/rails" # restore bin/rails
  end

  desc "template", "Configure dummy app"

  def template
    gsub_file("spec/dummy/config/boot.rb", %r{"../Gemfile"}, '"../../../Gemfile"')

    append_to_file("spec/dummy/config/boot.rb", <<~RUBY)

      $LOAD_PATH.unshift File.expand_path("../../../lib", __dir__)
    RUBY

    # Remove Koi migrations that will be loaded directly from Koi
    run "rm -f spec/dummy/db/migrate/*.koi.rb"

    reset_database

    # Update commit so we can more easily track changes
    run "cd spec/dummy && git add -A && git commit --amend -C HEAD" unless ENV["CI"]
  end

  desc "scaffold", "Scaffold example module"

  def scaffold
    reset_to_head # TODO only run when iterative, e.g. with a flag
    reset_database

    inside("spec/dummy") do
      run "rails g scaffold Post name:string title:string content:text"
      run "rails g koi:scaffold Post"
      run "rails db:migrate"
    end

    reset_database
    format_generated_files
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
  def reset_database
    run "rails app:db:drop app:db:setup"
  end

  # Format generated files
  def format_generated_files
    inside("spec/dummy") do
      run "git status --porcelain -u |grep '[.]rb'|awk '{print $2}'|xargs bundle exec rubocop -A || true"
      run "git status --porcelain -u |grep '[.]erb'|awk '{print $2}'|xargs bundle exec erblint -a || true"
    end
  end
end
