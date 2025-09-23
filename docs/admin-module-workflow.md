# Koi Admin Module Workflow

This playbook focuses on creating and maintaining admin modules with Koi’s generators. Use it when you need to scaffold a new CRUD surface, add fields after the fact, or tweak how results are presented inside the admin shell.

## What You Get

- An Active Record model with an `admin_search` scope and optional defaults from `koi:model`.
- An admin controller, request spec, GOV.UK-styled views, and wired routes from `koi:admin`.
- Automatic menu registration in `config/initializers/koi.rb` so the module appears once the server restarts.
- Headers, breadcrumbs, and tables that follow Koi’s conventions, including Turbo-compatible responses.

## End-to-end Workflow

1. **Model & migration**
   - Run `bin/setup` once per clone so dependencies and dummy data are ready.
   - For a brand-new table, prefer `bin/rails g koi:model Article title:string body:rich_text archived_at:datetime` so the model gains the `admin_search` scope and optional ordinal default scope automatically (`lib/generators/koi/model/model_generator.rb:9`). Attribute order here flows through to forms unless you override it later.
   - Add any migrations you need (including `ordinal:integer` or `archived_at:datetime` if you want drag-and-drop ordering or archiving support).
2. **Run migrations** with `bin/rails db:migrate` before invoking `koi:admin`; otherwise you must pass every attribute manually.
3. **Generate the admin surface**
   - `bin/rails g koi:admin Article` will invoke the controller, views, and route generators (`lib/generators/koi/admin/admin_generator.rb:9`). Passing attributes here lets you override field order; otherwise the migrated column order is used.
   - By default the generator introspects existing columns, attachments, rich text associations, and belongs_to references if you skip explicit attribute arguments (`lib/generators/koi/helpers/attribute_helpers.rb:15`).
   - Define a human-friendly `to_s` on the model (see **Pick a display attribute** below) so records render as titles across headers, breadcrumbs, and selects.
   - Wrap the generated controller in `module Admin` (or move it under `module Admin` yourself) so it inherits the helper stack from `Admin::ApplicationController`; without this you’ll hit `undefined method actions_list` errors in the admin shell.
   - Ensure `config/routes/admin.rb` and `config/initializers/koi.rb` exist (`bin/rails g koi:admin_route` will create them if missing) and restart the server once the generator finishes.
4. **Review navigation** – the route generator inserts your module into `config/initializers/koi.rb` under `Koi::Menu.modules` so it appears in the navigation dialog sorted alphabetically (`lib/generators/koi/admin_route/admin_route_generator.rb:46`).
5. **Wire authorisation/tests** after generation. The scaffolds don’t add policies; you supply them in the controller.
6. **Regenerate as needed** – when the table schema changes, re-run `bin/rails g koi:admin Article` (or rerun `koi:model`) to refresh forms, tables, and strong parameters. Generators ship with `--force` defaulting to true so they overwrite existing files; commit or stash your changes first so the diff is easy to reconcile.
7. **Smoke-test the UI** – sign in to `/admin`, create a record, view it, edit it, and delete it to confirm headings, helper methods, and navigation behave as expected.

### Regeneration Tips

- Use `--force=false` if you want to preview diffs without overwriting (`bin/rails g koi:admin Article --force=false`).
- Re-running `koi:admin_route` after you rename a module cleans up routes and the menu entry.
- If you have extensive manual edits to generated templates, consider extracting shared partials/components so future regenerations only touch wrapper code.
- Each generator defaults to `--force=true`, so commit or stash before rerunning to avoid losing work.

## Field Discovery & Supported Types

Koi maps ActiveRecord attributes and associations to GOV.UK form helpers and table cells via `AttributeTypes` (`lib/generators/koi/helpers/attribute_types.rb:30`).

| Schema hint | Form helper | Index cell | Show cell | Filters generated |
| --- | --- | --- | --- | --- |
| `string`, `text` | `form.govuk_text_field` | `row.text` | `row.text` | `attribute :name, :string` (`lib/generators/koi/helpers/attribute_types.rb:30`) |
| `integer` | `form.govuk_number_field` | `row.number` | `row.number` | `attribute :count, :integer` (`lib/generators/koi/helpers/attribute_types.rb:48`) |
| `boolean` | `form.govuk_check_box_field` | `row.boolean` | `row.boolean` | `attribute :flag, :boolean` (`lib/generators/koi/helpers/attribute_types.rb:66`) |
| `date` | `form.govuk_date_field` | `row.date` | `row.date` | `attribute :published_on, :date` (`lib/generators/koi/helpers/attribute_types.rb:84`) |
| `datetime` | _no form control generated_ | `row.datetime` | `row.datetime` | `attribute :starts_at, :date` (`lib/generators/koi/helpers/attribute_types.rb:102`) |
| `rich_text` | `form.govuk_rich_text_area` | — | `row.rich_text` (`lib/generators/koi/helpers/attribute_types.rb:116`) |
| Active Storage attachment | `form.govuk_image_field` | — | `row.attachment` (`lib/generators/koi/helpers/attribute_types.rb:126`) |
| `enum` (defined via `enum` API) | `form.govuk_enum_select` | `row.enum` | `row.enum` | `attribute :status, :enum` (`lib/generators/koi/helpers/attribute_types.rb:142`) |
| `belongs_to` | _no form control generated_ | — | `row.link` to the associated record (`lib/generators/koi/helpers/attribute_types.rb:136`) |
| `ordinal` column | Triggers orderable mode; no direct form field | Adds `row.ordinal` drag handle | — | — |
| `archived_at` column + `Koi::Model::Archivable` | Adds archive actions, archived view, bulk selection | — | `row.boolean :archived` (`lib/generators/koi/helpers/attribute_types.rb:163`) | — |

**Gotchas:**
- `datetime` and `belongs_to` columns don’t receive automatic form inputs. Add your own controls (e.g., `form.govuk_date_field(:starts_at)` or a `form.govuk_collection_select`) after generation.
- Attachment form controls default to `govuk_image_field`. Switch to `form.govuk_document_field` if the upload isn’t an image and update hints using `Koi::Form::Builder` overrides (`lib/koi/form/builder.rb:35`).
- On Rails 8+ declare enums with the positional syntax (`enum :status, { draft: 0, published: 1 }`). The older keyword form (`enum status: { ... }`) raises `ArgumentError: wrong number of arguments` when the generators constantize your model.
- Generated factories still assign integer enum values, so request specs post `'1'` and Rails 8 rejects it. Change the factory to use the symbolic key (e.g., `status { :draft }`) until the template is updated.
- Restart the Rails server after generating a module so `config/initializers/koi.rb` is reloaded—otherwise the new entry won’t show up in the admin modules menu.

## Pick a display attribute

Koi renders record instances in many places (`show` headers, breadcrumbs, select options) by calling `to_s`. Without an override you’ll see the Ruby inspector string (`#<Article:…>`), so set a sensible default in the model as soon as you scaffold the module:

```ruby
class Article < ApplicationRecord
  def to_s = title.presence || "Article ##{id}"
end
```

Picking a stable attribute (title, name, slug) keeps UI labels consistent across the admin shell, exports, and any custom components that rely on `to_s`.

**Alternatives:**
- If you prefer to vary what’s shown on the `show` page, replace the header markup directly: `<h1><%= article.title.presence || "Article ##{article.id}" %></h1>`.
- For more complex display logic (e.g., combining attributes), implement a decorator or view helper, but still provide a fallback `to_s` so other surfaces remain readable.

## Generated Forms & Custom Inputs

- Form templates iterate through the discovered attributes in order and render `govuk_*` helpers (`lib/generators/koi/admin_views/templates/_form.html.erb.tt:3`). Reorder or group fields by rearranging the generated ERB.
- If you pass attribute arguments to `koi:admin`, the generated forms respect the order you provide. When you omit arguments, discovery follows the migration order for columns—i.e., the order you specified when running `koi:model`—then appends attachments, rich text, and `belongs_to` associations in declaration order.
- `Koi::FormBuilder` injects admin-friendly buttons (`form.admin_save`, `form.admin_delete`) and smart defaults for file hints and ActionText direct uploads (`lib/koi/form/builder.rb:13`).
- The first attribute becomes the default index link via `row.link`, so choose something human-readable (title/name) or update the generated `index.html.erb`.
- For structured content components, mix in helpers from `Koi::Form::Content` to reuse heading/style selectors inside custom forms (`lib/koi/form/content.rb:8`).

### Date Inputs

`form.govuk_date_field` renders the GOV.UK composite day/month/year inputs, giving you accessible validation without relying on browser-specific date pickers. If you prefer a single text input or JS calendar, replace the helper after generation. For datetimes, add your own pair of date + time inputs—Koi does not guess the UX for you.

### Files & Attachments

- Controllers include `Koi::Controller::HasAttachments#save_attachments!` so failed validations don’t drop uploads (`app/controllers/concerns/koi/controller/has_attachments.rb:23`). Call it before re-rendering when you customise `create` / `update` flows.
- Multiple attachments are supported: the generator already whitelists arrays for attachment params when the attribute responds accordingly (`lib/generators/koi/admin_controller/templates/controller.rb.tt:110`).
- For non-image uploads swap `govuk_image_field` with `govuk_document_field` to get document-specific hints (size limits come from config in `lib/koi/form/builder.rb:35`).

## List Views, Ordering, and Pagination

### Table Layout

- Lists render inside `table_with`, and the first attribute becomes the linked column. Subsequent attributes follow in declaration order (`lib/generators/koi/admin_views/templates/index.html.erb.tt:33`).
- When the module is archivable, a selection column and bulk archive button appear automatically (`lib/generators/koi/admin_views/templates/index.html.erb.tt:19`).
- Summary pages render every “show attribute” using `row.text`, `row.enum`, etc. (`lib/generators/koi/admin_views/templates/show.html.erb.tt:10`).

### Collections & Filters

Each controller defines an inner `Collection` class extending `Admin::Collection` (search + Pagy) with type-aware filters for every attribute that supports it (`lib/generators/koi/admin_controller/templates/controller.rb.tt:124`). Filtering and search are powered by `Katalyst::Tables::QueryComponent`, automatically inserted when `query?` returns true (`lib/generators/koi/admin_views/templates/index.html.erb.tt:15`).

### Sorting & Pagination

- `config.sorting` defaults to the first string column unless the resource is orderable; you can override it manually inside the generated collection (`lib/generators/koi/helpers/attribute_helpers.rb:72`).
- Non-orderable modules paginate via Pagy with the `Koi::PagyNavComponent`, adding keyboard navigation (`app/components/koi/pagy_nav_component.rb:3`, `app/helpers/koi/pagy.rb:9`).

### Making a Module Orderable

- Add an `ordinal:integer` column to the table and rerun `koi:model` + `koi:admin`. The presence of an `ordinal` attribute enables the orderable branch (`lib/generators/koi/helpers/resource_helpers.rb:64`).
- The controller gains an `order` action that expects a hash of IDs/ordinals and consults `order_params` (`lib/generators/koi/admin_controller/templates/controller.rb.tt:118`).
- The index view renders `row.ordinal` and a `table_orderable_with` footer so users can drag-and-drop rows (`lib/generators/koi/admin_views/templates/index.html.erb.tt:27`). Pagination is disabled while orderable mode is active (`lib/generators/koi/helpers/resource_helpers.rb:68`).
- `koi:model` inserts a default scope that orders by `ordinal` so existing queries line up with the drag-and-drop UI (`lib/generators/koi/model/model_generator.rb:13`).

## Archiving & Bulk Actions

Including `Koi::Model::Archivable` in the model adds the `archived_at` scope and helpers (`app/models/concerns/koi/model/archivable.rb:17`). When the generator spots an `archived_at` column:

- Extra routes (`archive`, `restore`, `archived`) are added (`lib/generators/koi/admin_route/admin_route_generator.rb:33`).
- The index view adds a bulk archive action and a link to the archived list (`lib/generators/koi/admin_views/templates/index.html.erb.tt:21`).
- Destroy actions archive first, then delete once already archived (`lib/generators/koi/admin_controller/templates/controller.rb.tt:64`).

Finish the setup by following the dedicated archiving guide (`archiving.md`) for form wiring, strong parameters, UI surfacing, and testing expectations. That guide captures the manual steps discovered while building the Pages module.

## Navigation Registration

Every admin module is added to `Koi::Menu.modules` with a label derived from the namespace and model name. The generator rewrites the initializer block, keeping entries alphabetical (`lib/generators/koi/admin_route/admin_route_generator.rb:46`). Move the item into groups or submenus by editing `config/initializers/koi.rb` after generation. Because this lives in an initializer, restart the app (or reload Spring) before expecting the navigation dialog to pick up changes.

## Pagination UX

`Koi::Controller` sets default component bindings for tables, queries, and pagination (`app/controllers/concerns/koi/controller.rb:13`). Pagy navigation gains a Stimulus controller so admins can page with ←/→ shortcuts (`app/helpers/koi/pagy.rb:9`). The whole table is wrapped with `Koi::TableComponent`, which ensures consistent styling and makes helper cells such as `row.link` and `row.attachment` available (`app/components/koi/table_component.rb:4`).

## Common Customisations

- **Add custom filters** by extending the inner `Collection` and declaring attributes manually; anything you add shows up in `table_query_with` automatically.
- **Override form layouts** using ViewComponents or partials if you need multi-column layouts—just ensure the submit buttons continue to call `form.admin_save` so styles remain consistent.
- **Additional actions** go inside the controller and can be surfaced in the header via `actions_list`.
- **Non-standard inputs** (e.g., slug sync, toggles) can hook into existing Stimulus controllers such as `sluggable` or `show-hide`.
- **Front-end routes** – when marketing pages should appear at `/slug` instead of `/pages/slug`, use the [`root-level-page-routing.md`](./root-level-page-routing.md) constraint pattern after scaffolding the public controller.

## Generator Reference

### `koi:model`

- Shares options with `rails g model` (`--timestamps=false`, `--parent=`, etc.).
- Adds the `admin_search` scope automatically, falling back to SQL `LIKE` when no string columns exist.
- Inserts a default scope when an `ordinal` column is present to support orderable lists.

### `koi:admin`

- Usage: `bin/rails g koi:admin NAME [field:type ...]`.
- Options: `--force=false`, `--skip-admin_controller`, `--skip-admin_views`, `--skip-admin_route` when regenerating selectively.
- Delegates to the sub-generators with the same attribute list; rerun after schema changes to refresh strong params and templates.

### Sub-generators

- `koi:admin_controller`, `koi:admin_views`, and `koi:admin_route` are available individually for targeted refreshes. They honour the same attribute parsing and `--force` flag.

## Gotchas & Reminders

- Generators overwrite files without prompting. Keep commits small so you can regenerate confidently.
- `belongs_to` relationships only appear on the show page; add your own form fields/filters if you need to edit them in the UI.
- When handling attachments, always call `save_attachments!` before rendering to avoid losing uploads.
- Pagination is disabled for orderable lists. If you have a large dataset, consider a dedicated reorder screen instead of relying on the default drag-and-drop.
- Navigation entries are stored in code, not the database. Remember to adjust `config/initializers/koi.rb` when you rename modules.
- After scaffolding, step through the CRUD screens (create → show → edit → delete) to confirm helpers, validations, and menu wiring behave as expected.

With these patterns in hand you can scaffold, regenerate, and customise Koi admin modules quickly while staying inside the conventions baked into the engine.
