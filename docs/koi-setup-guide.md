# Koi Setup Guide

Use this guide to get a Koi-backed Rails application running locally with an admin account and a passing test suite. It favours the `koi-template` generator (recommended for new projects) and includes a manual path for existing apps. Follow every "Verify" checkpoint to ensure the environment is ready for development.

## Prerequisites

- macOS or Linux with Homebrew/apt tooling.
- Ruby 3.2+ (managed via `rbenv` or `ruby-install`), Bundler, and Rails 7.1 or newer (`gem install rails`).
- SQLite 3 (ships with macOS; `brew install sqlite` or `sudo apt install sqlite3` on Linux).
- Optional: Foreman (`gem install foreman`) for the `bin/dev` workflow.
- Optional (engine contributors only): Node.js 18+ and Yarn for rebuilding Koi’s bundled admin JavaScript.

**Verify**

```sh
ruby -v       # expect 3.2.x
rails -v      # expect 7.1.x or newer
sqlite3 -version
# Optional for engine contributors
# node -v && yarn -v
```

## Standard Path: Bootstrap with koi-template (Recommended)

### 1. Generate a new Rails app that targets SQLite

Run `rails new` with the template and the SQLite adapter (swap `<app-name>` and the template path if you cloned `koi-template` elsewhere).

```sh
rails new <app-name> -d sqlite3 \
  --skip-action-cable --skip-action-mailbox --skip-action-mailer \
  --skip-ci --skip-dev-gems --skip-docker --skip-git \
  --skip-jbuilder --skip-kamal --skip-keeps --skip-solid \
  --skip-system-test --skip-test --skip-thruster \
  -a propshaft \
  -m <path-to-koi-template>/template.rb
```

If you prefer to run it from GitHub, swap the `-m` argument for `https://raw.githubusercontent.com/katalyst/koi-template/main/template.rb`.

If the generator stops part-way (for example, because Bundler could not reach the network), delete the partially created directory (`rm -rf <app-name>`) before retrying. This avoids the follow-up run prompting to overwrite files mid-generation.

The template installs dependencies, copies initialisers, runs migrations (including Koi), and commits the result.

**Verify**

```sh
cd <app-name>
bin/rails about
```

You should see the application banner without errors.

### 2. Install gems and prepare the database

The generated project ships with a `bin/setup` script that installs Bundler, resolves gems, prepares the SQLite database, clears logs, and restarts the app server.

```sh
bin/setup
```

**Verify**

```sh
bin/rails db:version     # prints the latest schema version
sqlite3 db/development.sqlite3 '.tables'  # shows koi_* tables among others
```

Seeing tables such as `admin_users`, `koi_menu_items`, and `url_rewrites` confirms migrations ran.

### 3. Seed Koi defaults and create an admin user

The template already appends `Koi::Engine.load_seed` to `db/seeds.rb`. Run the seeds; in development this creates the default Katalyst admin (name from `id -F`, email `<user>@katalyst.com.au`, password `password`). You can use that seed account immediately or create additional admins as needed. See `user-management.md` for detailed guidance on how the seeded account works and how to adjust it safely.

```sh
bin/rails db:seed
```

Create a working admin account with the helper script:

```sh
bin/admin-adduser
```

- **Katalyst employees**: when you run the script in an environment where `Rails.env.local?` returns true (the common local setup in Katalyst projects) and your Unix account exposes a full name, the script uses `<your-unix-user>@katalyst.com.au` automatically.
- **Explicit creation**: supply flags if the defaults are missing or you are onboarding a client.

```sh
bin/admin-adduser -n "Casey Client" -e "casey@example.com"
```

If the seed already created an account for your shell user, `bin/admin-adduser` exits early with a warning. In that case either pass `-e` to create a different user, or run `bin/admin-reset <email>` to generate a fresh login link for the existing account. `user-management.md` covers additional workflows, including changing the seeded email and avoiding redirect loops during logout.

The script prints either a full login URL or a relative `/admin/session/token/<token>` path; copy it into your browser to finish activation.

**Verify**

- `Admin::User.count` should be ≥ 1: `bin/rails runner 'puts Admin::User.count'`.
- A login URL or path appears in the script output.

### 4. Start the application and confirm the UI

Use `bin/dev` (Foreman) to launch Rails, CSS, and JS watchers. Fallback: `bin/rails server` if you do not have Foreman installed.

```sh
bin/dev
```

Visit these URLs in your browser:

- `http://localhost:3000/` – shows the scaffolded homepage from the template.
- `http://localhost:3000/admin` – loads the Koi admin shell.

Log in using the credentials or token from the previous step. In development, `Koi.config.authenticate_local_admins` signs you in automatically when an `Admin::User` exists with your shell email. Disable this behaviour by adding `Koi.configure { |c| c.authenticate_local_admins = false }` in `config/initializers/koi.rb` if you need to exercise the full login flow.

**Verify**

- The admin header, navigation dialog, and default dashboard widgets render without exceptions.
- You can visit `/admin/admin_users` and see the account you created.

### 5. Run the test suite

Koi projects generated by the template use RSpec with system specs that assert the admin login flow works.

```sh
bundle exec rspec
```

**Verify**

- Command exits with status `0`.
- The summary reports `0 failures` (a fresh template run typically shows ~10–20 examples).

At this point you have a working development environment, an accessible admin UI, and green tests—ready for feature work.

## Alternative Path: Add Koi to an Existing Rails App

Follow this track when you cannot regenerate the app from the template (e.g. retrofitting Koi into a legacy project).

### 1. Add dependencies and generators

1. Add the gem to your `Gemfile`:
   ```ruby
   gem "katalyst-koi"
   ```
2. Run `bundle install`.
3. Ensure Rails generators align with Koi expectations (no assets/helpers, RSpec enabled) and that Koi loads immediately after the main app. Add the following to `config/application.rb` inside the application class if it is not present:
   ```ruby
   config.generators do |g|
     g.assets false
     g.helper false
     g.stylesheets false
     g.test_framework :rspec
   end

   config.railties_order = [:main_app, Koi::Engine, :all]
   ```

**Verify**

```sh
bundle exec rails about
```

The command should report versions without raising load errors.

### 2. Install Koi assets, routes, and migrations

Run the engine installers and generators from your app root:

```sh
bin/rails katalyst_koi:install:migrations
bin/rails db:migrate
bin/rails g koi:admin_route
```

- Add `draw(:admin)` to `config/routes.rb` if the generator did not append it:
  ```ruby
  Rails.application.routes.draw do
    draw(:admin)
    # ...your existing routes...
  end
  ```
- Review `config/initializers/koi.rb` and keep the default menu buckets unless you have a bespoke navigation setup.

**Verify**

```sh
bin/rails routes | grep '^admin'
```

You should see entries such as `admin_root` and `admin_session`.

### 3. Configure seeds and create an admin

Append the engine seeds so core data (default admin, cache tools, well-known entries) loads in development:

```ruby
# db/seeds.rb
Koi::Engine.load_seed
```

Then run the seeds and create an admin user suitable for your environment.

```sh
bin/rails db:seed
bin/rails runner "Admin::User.create!(name: 'Admin', email: 'admin@example.com', password: 'changeme') unless Admin::User.exists?(email: 'admin@example.com')"
```

For employee-specific accounts, reuse the helper from the template by copying `bin/admin-adduser` into your project or building an equivalent Rake task.

**Verify**

```sh
bin/rails runner 'puts Admin::User.pluck(:email)'
```

Confirm the expected email(s) appear.

### 4. Boot the app and validate the admin shell

Start the server (`bin/dev` or `bin/rails server`), visit `/admin`, and complete a login with the credentials you created.

**Verify**

- `/admin` redirects unauthenticated users to `/admin/session/new`.
- After logging in, `/admin` renders the dashboard without errors.

### 5. Run your test suite

Execute the project's standard tests (RSpec or Minitest) to ensure Koi integrations did not break existing behaviour.

```sh
bundle exec rspec           # or bin/rails test if you use Minitest
```

Confirm the suite passes; investigate any failures related to fixtures or authentication before continuing.

## Verification Checklist

- `bin/rails about` succeeds.
- `bin/rails db:version` reports the latest migration and SQLite tables include `admin_users`.
- You can generate or reset an admin using `bin/admin-adduser` / `bin/admin-reset` or your custom script.
- Visiting `/admin` in the browser presents the Koi UI and allows navigation between default sections.
- `bundle exec rspec` (or your equivalent test command) finishes with `0 failures`.

## Troubleshooting

- **`bin/admin-adduser` exits early:** Pass `-n` and `-e` explicitly; some shells (especially Linux) do not support `id -F` for deriving your full name.
- **Login token prints as a relative path:** Prefix it with `http://localhost:3000` in development. Configure `Rails.application.routes.default_url_options[:host] = "localhost:3000"` for a persistent fix.
- **Auto-login hides the sign-in form:** Temporarily disable `Koi.config.authenticate_local_admins` in the initializer to test credentials manually.
- **Missing migrations or tables:** Re-run `bin/rails db:prepare` followed by `bin/rails db:migrate`. If you added Koi to an existing app, ensure fixtures/factories load `Admin::User` records as needed for specs.

With these steps finished you have a reproducible workflow for standing up Koi locally—either via the purpose-built template or by hand—complete with an admin account, a browsable UI, and passing tests.
