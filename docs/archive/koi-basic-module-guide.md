# Building a Basic Koi Module

Use this guide when you want the lightest-possible CRUD surface in Koi: no ordering, no archiving, no associations—just a Rails model backed by standard columns and the admin scaffolding that Koi generates for you. It is written for both humans and coding LLMs so the process can be repeated reliably.

## What a Koi Module Provides

After generation you get:

- An ActiveRecord model wired with an `admin_search` scope and optional defaults from `koi:model` (`lib/generators/koi/model/model_generator.rb`).
- An admin controller, requests spec, GOV.UK-flavoured views, and fully wired routes from `koi:admin` (fan-out to controller, views, and route generators under `lib/generators/koi`).
- Automatic menu registration in `config/initializers/koi.rb` so the module appears in the admin UI once the server restarts.
- Form, table, and show layouts that follow Koi’s conventions, including breadcrumb/header wiring and Turbo-ready responses.

## Before You Start

1. Run `bin/setup` once per repository clone to install dependencies and prepare `spec/dummy` if you have not already.
2. Ensure `config/routes/admin.rb` and `config/initializers/koi.rb` exist. If not, run `bin/rails g koi:admin_route` and restart the server.
3. Decide on a model name and the columns you need. For the “basic module” pattern, stick to primitive columns (string, text, integer, boolean, date, datetime). Skip `archived_at`, `ordinal`, attachments, and associations so the generated UI stays minimal.

## Step-by-step Workflow

### 1. Generate the model and migration

Use the `koi:model` generator so the model receives the `admin_search` scope.

```sh
bin/rails g koi:model Article title:string summary:text published_on:date featured:boolean
```

- The generator accepts the same options as `rails g model` (for example `--skip-fixtures`, `--timestamps=false`).
- `koi:model` inserts either a `pg_search_scope` or a SQL fallback depending on whether `PgSearch::Model` is loaded (`lib/generators/koi/model/model_generator.rb`).

### 2. Run the migration

```sh
bin/rails db:migrate
```

Running the migration is essential before invoking `koi:admin`. If you skip this step, `koi:admin` cannot introspect the schema and you will have to pass every column to the generator manually.

### 3. Generate the admin surface

```sh
bin/rails g koi:admin Article
```

Key behaviours to understand:

- With no attribute arguments, `koi:admin` inspects the model you just migrated and collects columns, rich text associations, enums, and attachments (`lib/generators/koi/helpers/attribute_helpers.rb`). This keeps the form/view templates in sync with the database.
- To control field order explicitly, pass attributes in the desired sequence: `bin/rails g koi:admin Article title:string summary:text published_on:date featured:boolean`. The generator uses the attribute array as-is when rendering `_form.html.erb` (`lib/generators/koi/admin_views/templates/_form.html.erb.tt`).
- The admin generator fans out to:
  - `koi:admin_controller` → `app/controllers/admin/articles_controller.rb` and `spec/requests/admin/articles_controller_spec.rb`.
  - `koi:admin_views` → form, index, new/edit, and show templates under `app/views/admin/articles`.
  - `koi:admin_route` → adds `resources :articles` to `config/routes/admin.rb` and updates the menu initializer (`lib/generators/koi/admin_route/admin_route_generator.rb`).
- All three generators run with `--force=true` by default, so files are overwritten without a prompt. Commit or stash before regenerating.

### 4. Restart the server

The navigation entry lives in `config/initializers/koi.rb`, so restart Spring/your Rails server to see the new module in the admin menu. Without the restart, the initializer is not reloaded and the menu will not change.

### 5. Verify CRUD behaviour

1. Sign in at `/admin`.
2. Confirm the module appears in the menu (alphabetically unless you reorder the initializer).
3. Create a record and save it—forms use GOV.UK inputs wired in `_form.html.erb`.
4. Visit the show page. The `<h1>` renders `record.to_s` (`lib/generators/koi/admin_views/templates/show.html.erb.tt:6`), so define `def to_s = title` (or another identifying attribute) in your model to display the correct heading.
5. Edit and delete to confirm the controller wiring and flash notices work as expected.

## Generator Reference for Basic Modules

### `koi:model`

- Inherits every option from `rails g model` (timestamps, parent class, fixtures, etc.).
- Adds `admin_search` automatically. If your schema lacks any string columns, the fallback scope becomes a simple `where` on whatever columns exist.
- Adds a default scope when an `ordinal` column is present; avoid that column for the “basic module” path.

### `koi:admin`

- Signature: `bin/rails g koi:admin NAME [field:type ...]`.
- Options: `--force=false` (preview without overwriting), `--skip-admin_controller`, `--skip-admin_views`, `--skip-admin_route` (skip individual hooks if you need to customise manually).
- Generates helpers for index/new/edit/show routes based on the namespace logic in `lib/generators/koi/helpers/resource_helpers.rb`.

### `koi:admin_controller`, `koi:admin_views`, `koi:admin_route`

You rarely run these directly, but they are available for targeted regeneration (for example, `bin/rails g koi:admin_views Article` if you only changed columns). They share the same attribute parsing and `--force` option.

## Column Types and UI Output

The attribute-introspection layer maps common Rails column types to Koi’s form and table helpers (`lib/generators/koi/helpers/attribute_types.rb`). For basic modules, expect the following defaults:

| Column type | Form helper | Index cell | Show cell |
| --- | --- | --- | --- |
| `string`, `text` | `form.govuk_text_field` | `row.text` | `row.text` |
| `integer` | `form.govuk_number_field` | `row.number` | `row.number` |
| `boolean` | `form.govuk_check_box_field` | `row.boolean` | `row.boolean` |
| `date` | `form.govuk_date_field` | `row.date` | `row.date` |
| `datetime` | _no input generated_; add one manually if you need it | `row.datetime` | `row.datetime` |
| `enum` | `form.govuk_enum_select` | `row.enum` | `row.enum` |

Types not listed fall back to the string helpers. If you introduce attachments, rich text, or associations later, rerun the generator and update the form manually as needed.

## Field Ordering Rules

- `koi:admin` renders fields in the order of the `attributes` array it receives. When introspecting a migrated model, that order matches how columns appear in the database schema. Passing explicit attributes lets you override it.
- The first column becomes the clickable link on the index table (`lib/generators/koi/admin_views/templates/index.html.erb.tt:22`). Choose an identifying field (for example, `title`) if you want a particular column to link to the show page.
- To reorder after generation, edit `_form.html.erb`, `index.html.erb`, and `show.html.erb` manually or rerun the generator with the desired order.

## Regeneration Strategy

- When the schema changes (new column, renamed field), rerun `koi:admin` for that model. The generator rewrites controllers, views, routes, and menu entries to match the new schema.
- Because `--force` defaults to true, regeneration overwrites local edits. Either:
  - keep custom logic in separate partials/components that you reapply after regeneration, or
  - use `--force=false` to generate side-by-side files and copy changes across.
- You can regenerate just the controller, views, or routes if that is all that changed.

## Putting It All Together (Worked Example)

1. **Generate model:** `bin/rails g koi:model Announcement title:string body:text published_on:date featured:boolean`
2. **Migrate:** `bin/rails db:migrate`
3. **Generate admin:** `bin/rails g koi:admin Announcement`
4. **Set the display name:**
   ```ruby
   # app/models/announcement.rb
   class Announcement < ApplicationRecord
     def to_s = title
   end
   ```
5. **Restart:** `bin/dev` (or restart your existing server process).
6. **Verify in the UI:** create, edit, show, and delete announcements from `/admin/announcements`.

Following these steps yields a fully functional, minimal CRUD module that plays nicely with the rest of Koi. When you are ready for richer behaviour (archiving, ordering, attachments), jump to `docs/admin-module-workflow.md` for the advanced patterns.
