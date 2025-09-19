# Koi Admin User Guide

This guide explains how to use Koi to build consistent administration areas in client projects. It covers setup, configuration, the standard features that ship with the engine, and the patterns you'll follow when building custom modules. Share this document with new team members who need to work in Koi-backed apps.

## Documentation Map

- **Setting up a project:** see [`koi-setup-guide.md`](./koi-setup-guide.md) for end-to-end bootstrap steps (template workflow and retrofit path).
- **Managing admin users:** see [`user-management.md`](./user-management.md) for provisioning, authentication options, and day-to-day maintenance tasks.
- **Building admin modules:** see [`admin-module-workflow.md`](./admin-module-workflow.md) for the full generator-driven process and advanced tips on ordering, archiving, and regeneration.

## What Koi Provides (and What It Does Not)

Koi is a Rails engine that installs a fully-featured admin shell. It gives you:

- Opinionated layouts, navigation, and styling, wired for Turbo, Stimulus, and GOV.UK form components.
- Authentication flows (password, passkeys/WebAuthn, optional OTP-based MFA, and passwordless login links) using the built-in `Admin::User` model.
- Shared administrative tooling such as menu management, cache clearing, URL rewrites, and `.well-known` document publishing.
- Helpers, Stimulus controllers, and view components that streamline CRUD screens built on `Katalyst::Tables` and `Katalyst::Content`.
- Generators to scaffold models, controllers, views, and navigation entries that match the engine’s conventions.

Koi does **not** attempt to model business logic for client applications. You still add your own ActiveRecord models, policies/authorization, background jobs, and complex workflows. Koi’s job is to make the admin UI predictable and accessible across projects.

## Getting Started

Follow the dedicated setup playbook when bootstrapping or retrofitting an app—see [`koi-setup-guide.md`](./koi-setup-guide.md) for prerequisites, template usage, manual install steps, and verification checkpoints.

At a glance, a fresh project typically involves:

1. Creating/bootstrapping a Rails app (the `koi-template` handles most defaults).
2. Installing Koi with `bin/rails katalyst_koi:install:migrations` and running migrations.
3. Generating `config/routes/admin.rb` and `config/initializers/koi.rb` via `bin/rails g koi:admin_route`.
4. Seeding an initial `Admin::User` and ensuring Koi assets are referenced.
5. Starting the server and visiting `/admin` to confirm the shell loads.

Use the setup guide for explicit commands, alternate workflows, and troubleshooting tips.

### Development Tips

- In development the default config `Koi.config.authenticate_local_admins` automatically signs in a matching admin user based on your shell `USER` (`app/controllers/admin/sessions_controller.rb:18`). Disable this for demos by setting `Koi.configure { |c| c.authenticate_local_admins = false }`. See `user-management.md` for deeper guidance on managing seeded admins and adjusting their emails.
- Run `bundle exec rspec` and `bundle exec rake lint` before committing changes, matching repository guidelines.
- Use `yarn build` (and `yarn clean` if you need to clear previous artifacts) to regenerate `app/assets/builds/katalyst/koi.min.js` if you change the JavaScript package.

## Configuration Reference

Configure Koi in an initializer (created by `koi:admin_route`) or any boot file. The defaults live in `lib/koi/config.rb`.

| Setting | Default | Purpose |
| --- | --- | --- |
| `admin_name` | `"Koi"` | Display name in page titles and the header (`app/views/layouts/koi/application.html.erb:7`). |
| `authenticate_local_admins` | `Rails.env.development?` | Auto-login behaviour used in `Admin::SessionsController#authenticate_local_admin` (`app/controllers/admin/sessions_controller.rb:59`). |
| `resource_name_candidates` | `%i[title name]` | Candidate attributes used by view helpers to label resources. |
| `admin_stylesheet` | `"admin"` | Stylesheet tag rendered in layouts (`app/views/layouts/koi/application.html.erb:21`). |
| `admin_javascript_entry_point` | `"@katalyst/koi"` | JavaScript import map entry used by layouts (`app/views/layouts/koi/application.html.erb:24`). |
| `document_mime_types` / `image_mime_types` | Lists of allowed MIME types | Used by `Koi::Form::Builder` when rendering file fields (`lib/koi/form/builder.rb:28`). |
| `document_size_limit` / `image_size_limit` | `10.megabytes` | Size hints shown next to upload fields. |

Call `Koi.configure` in an initializer to override values:

```ruby
Koi.configure do |config|
  config.admin_name = "Acme CMS"
  config.admin_stylesheet = "admin_bundle"
  config.admin_javascript_entry_point = "application"
end
```

### Menu Configuration

`Koi::Menu` drives the navigation modal (`lib/koi/menu.rb`). The initializer created by `koi:admin_route` seeds three menu buckets:

- `Koi::Menu.priority` – always shown first. Defaults include “View website” and “Dashboard”.
- `Koi::Menu.modules` – the main listing for your admin modules. Generators update this automatically.
- `Koi::Menu.advanced` – extra utilities such as Admin Users, URL Rewrites, `.well-known` documents, Sidekiq, Flipper, and the “Clear cache” button.
- `Koi::Menu.quick_links` – used on the dashboard to highlight shortcuts.

Each hash key becomes a heading and each value is either a path or a nested hash for grouped links. Update the initializer to curate links:

```ruby
Koi::Menu.modules = Koi::Menu.modules.merge(
  "Content" => {
    "Pages" => "/admin/pages",
    "News"  => "/admin/news_items",
  }
)

Koi::Menu.quick_links = {
  "Support tickets" => "/admin/support_tickets",
  "Release notes"   => "/admin/releases",
}
```


## Authentication and Security

Koi wraps multiple authentication flows (password, OTP, passkeys, magic links) around `Admin::User`. For provisioning steps, invitation flows, and operational scripts, see [`user-management.md`](./user-management.md).

- `Admin::SessionsController` coordinates the multi-step login sequence and hands off to the correct credential flow.
- `Koi::Middleware::AdminAuthentication` guards all `/admin/**` routes, while `Koi::Controller::RecordsAuthentication` records sign-in metadata.
- OTP/WebAuthn enrolments live in the admin profile, and cache clearing is surfaced via `Admin::CachesController` using the same middleware.
- Koi leaves authorisation to the host app—layer Pundit, ActionPolicy, or CanCanCan over generated controllers.

## Navigation and Layout

### Layouts and Frames

- `app/views/layouts/koi/application.html.erb` is the default admin layout. It sets up the page title, includes configured assets, renders flash messages, and wraps page content in `.wrapper` containers.
- Turbo frame responses use `app/views/layouts/koi/frame.html.erb`, ensuring Turbo includes CSRF meta tags and the admin assets when rendering partial screens.
- The login area uses `app/views/layouts/koi/login.html.erb` with a slimmed-down stylesheet for a focused sign-in experience.

### Header and Actions

- Use `content_for :header` in your views to inject headings, breadcrumbs, and action links as shown in `app/views/admin/admin_users/index.html.erb` and `show.html.erb`.
- `Koi::HeaderHelper#breadcrumb_list` and `#actions_list` render accessible navigation strips (`app/helpers/koi/header_helper.rb`). They accept arbitrary list content.
- `Koi::HeaderComponent` wraps the same functionality in a ViewComponent when you prefer a component-based API (`app/components/koi/header_component.rb`).

### Navigation Modal

- The navigation dialog at the top-right is rendered via `app/views/layouts/koi/_application_navigation.html.erb`. It composes menu items using `navigation_menu_with` from `Katalyst::Navigation` and lists the current admin along with log-out links.
- The `navigation` Stimulus controller powers quick filtering, keyboard shortcuts, and modal open/close interactions (`app/javascript/koi/controllers/navigation_controller.js`). Keyboard mappings are defined on the `<body>` element (`app/views/layouts/koi/application.html.erb:27`).

### Dashboard Quick Links

`Admin::DashboardsController` renders `Koi::Menu.dashboard_menu` so you can surface shortcuts for common admin tasks (`app/controllers/admin/dashboards_controller.rb` and `app/views/admin/dashboards/show.html.erb`). Update `Koi::Menu.quick_links` to curate this list.

## Building Admin Modules

For the step-by-step workflow—including generator usage, field ordering rules, archiving, ordering, and regeneration—refer to [`admin-module-workflow.md`](./admin-module-workflow.md). The notes below summarise the moving parts you will encounter once the scaffolding is in place.

### Controllers

`koi:admin` generates controllers under `Admin::` that inherit from `Admin::ApplicationController` so they pick up `Koi::Controller` (pagination, helper inclusion, CSRF/turbo-aware layout handling). The generator wires:

- An inner `Collection` class backed by `Katalyst::Tables::Collection` for sorting, filtering, and pagination.
- Strong parameters built with `params.expect`, covering scalar attributes, attachments, and rich text.
- Optional collection actions such as `archived`, `archive`, `restore`, and `order` depending on detected columns.
- Matching GOV.UK-flavoured views plus RESTful routes/menu entries so the module appears immediately in navigation.

When you build custom actions, call `save_attachments!` before re-rendering to preserve uploads (`app/controllers/concerns/koi/controller/has_attachments.rb:14`).

### Collections and Tables

`Admin::Collection` (`app/models/admin/collection.rb`) base class sets up search filtering using either `pg_search` or SQL `LIKE`. In each controller you define an inner `Collection` class to describe filterable attributes:

```ruby
class Collection < Admin::Collection
  config.sorting  = :name
  config.paginate = true

  attribute :name, :string
  attribute :status, :enum
  attribute :published_on, :date
end
```

In views, use the provided helpers:

```erb
<%= table_query_with(collection:) %>

<%= table_with(collection:) do |row, record| %>
  <% row.link :name %>
  <% row.boolean :published? %>
  <% row.date :published_on %>
<% end %>

<%= table_pagination_with(collection:) %>
```

`Koi::Tables::Cells` adds extra helper cells:

- `row.link` outputs a link to the record’s show (or a custom URL) (`app/components/concerns/koi/tables/cells.rb:18`).
- `row.attachment` displays ActiveStorage attachments as downloads/thumbnails (`app/components/concerns/koi/tables/cells.rb:44`).
- Use `table_selection_with` for bulk actions, as shown in `app/views/admin/admin_users/index.html.erb`.

### Forms

`Koi::FormBuilder` combines `GOVUKDesignSystemFormBuilder` with helper shortcuts (`lib/koi/form_builder.rb`). Key helpers include:

- `form.admin_save` / `form.admin_delete` / `form.admin_archive` / `form.admin_discard` for consistent action buttons (`lib/koi/form/builder.rb:13`).
- Automatic admin routes in `form_with` via `Koi::FormHelper` (`app/helpers/koi/form_helper.rb`).
- File field helpers use size limits from configuration.
- `Koi::Form::Content` provides macros for content block editors (heading fields, target selectors, etc.) used with `Katalyst::Content`.

Remember to call `govuk_formbuilder_init` once when you render password fields so the GOV.UK show/hide toggle initialises (`app/views/admin/sessions/password.html.erb:12`).

### Model Concerns

- `Koi::Model::Archivable` adds an `archived_at` flag, default scopes, and helper methods such as `archive!`/`restore!` (see `app/models/concerns/koi/model/archivable.rb`). Use it for content that can be soft-deleted from the interface.
- `Koi::Model::OTP` exposes `requires_otp?` and `otp` helpers for models that store an `otp_secret` (`app/models/concerns/koi/model/otp.rb`). It is already included in `Admin::User` but can be reused if you expose other MFA-enabled admin records.

### Modals and Turbo Frames

- `koi_modal_tag` renders a Turbo-driven modal frame (`app/helpers/koi/modal_helper.rb`). Wrap forms inside the modal and pair with `koi_modal_header` / `koi_modal_footer` for consistent markup.
- The `modal` Stimulus controller manages lifecycle events (open, close, dismiss) and automatically closes on successful submissions when the submit button has `data-close-dialog` (`app/javascript/koi/controllers/modal_controller.js`).
- The self-variant views (e.g., `show.html+self.erb`) demonstrate how to provide tailored layouts when the current user is editing their own record. Rails automatically renders the `:self` template when `request.variant << :self` is set in the controller (`app/controllers/admin/admin_users_controller.rb:115`).

### Content and Navigation Editors

Koi integrates the `Katalyst::Content` and `Katalyst::Navigation` engines:

- `Katalyst::Content.config.base_controller` is set to `Admin::ApplicationController` so content editing screens run inside the Koi layout (`lib/koi/engine.rb:34`).
- Error summaries for both engines render through Koi components (`app/components/koi/content/editor/errors_component.rb` and `app/components/koi/navigation/editor/errors_component.rb`).
- Use `mount Katalyst::Content::Engine, at: "admin/content"` directly from Koi’s routes (`config/routes.rb:24`) and manage navigation structures under `/admin/navigation`.

## Supporting Modules

### Admin Users

Koi ships a full admin-user management surface (index, profile, OTP/passkey enrolment, archive/restore). Treat it as the reference implementation for new CRUD modules. For provisioning flows, CLI helpers, and operational policies, see [`user-management.md`](./user-management.md).

### URL Rewrites

`UrlRewrite` records redirect stale paths to new URLs (`app/models/url_rewrite.rb`). The middleware `Koi::Middleware::UrlRedirect` intercepts 404 responses and applies active rewrites before the response is returned (`lib/koi/middleware/url_redirect.rb`). Use the admin UI under `/admin/url_rewrites` to manage entries.

### .well-known Documents

`WellKnown` allows administrators to publish arbitrary files under `/.well-known/:name` (`app/models/well_known.rb`). The public route is defined in `config/routes.rb:33`. Use this for ownership proofs and verification files.

### Release Metadata

`Koi::Release` reads `VERSION` and `REVISION` files and exposes them as `<meta>` tags in the head (`lib/koi/release.rb`). Override or populate these files in deployments so admins can see which build is running (`app/views/layouts/koi/_application_header.html.erb:8`).

### Caching Controls

`Koi::Caching` exposes two settings (`lib/koi/caching.rb`): `enabled` and `expires_in`. Toggle or override them if you integrate custom caching strategies.

### Flipper Integration

If `Flipper` is present, the initializer at `config/initializers/flipper.rb` registers an `:admins` group that considers any unarchived `Admin::User` a feature toggle actor.

## JavaScript and Styling

### Stimulus Controllers

Koi auto-loads Stimulus controllers from `app/javascript/koi/controllers/index.js`. Highlights include:

- `keyboard` – global keyboard shortcuts for search (`/`), create (`N`), navigation (`G`), cancel (Esc), and pagination arrows (`app/javascript/koi/controllers/keyboard_controller.js`).
- `navigation` / `navigation-toggle` – open, close, and filter the navigation dialog.
- `flash` – dismiss flash messages.
- `modal` – manage Turbo frame modals.
- `form-request-submit` – programmatically trigger `form.requestSubmit()`.
- `webauthn-authentication` / `webauthn-registration` – handle passkey login/registration flows by exchanging JSON with the WebAuthn browser APIs (`@github/webauthn-json`).
- `pagy-nav` – integrates keyboard pagination shortcuts with Pagy nav links.
- `clipboard` – copy invitation URLs to the clipboard.
- `show-hide` and `sluggable` – minor UX niceties for collapsible panels and slug fields.

If you add controllers in your host app, either extend `app/javascript/koi/application.js` or mount them under your own namespace and load them alongside Koi.

### Custom Elements and Utilities

- `koi-toolbar` custom element wraps query toolbars with appropriate ARIA roles (`app/javascript/koi/elements/toolbar.js`).
- `Transition` utility provides a composable API for show/hide animations and is used by the `show-hide` controller (`app/javascript/koi/utils/transition.js`).

### Asset Bundling

- The Rollup config (`rollup.config.mjs`) builds minified bundles into `app/assets/builds/katalyst`. Run `yarn build` after editing JavaScript modules.
- Stylesheets live under `app/assets/stylesheets/koi`. `index.css` imports GOV.UK utilities, content/navigation/table stylesheets, and engine-specific layers. Extend these files (or override custom properties) in your host app’s own stylesheet bundle if you need branding tweaks.
- Icons are pure CSS masks defined in `app/assets/stylesheets/koi/icons.css`; add new masks next to `app/assets/images/koi/logo.svg` and follow the same pattern.

## Working With Content

- `Koi::Form::Content` convenience methods help build structured content blocks (headings, URLs, targets, etc.) when authoring `Katalyst::Content` components (`lib/koi/form/content.rb`). Include this module in your form object or `FormBuilder` to reuse the macros.
- The content editor Stimulus controllers are included via the `@katalyst/content` package automatically (loaded in `app/javascript/koi/controllers/index.js`).
- Direct uploads for Action Text fields are wired through the same Stimulus controllers with preconfigured data attributes in `Koi::Form::Builder#govuk_rich_text_area`.

## Testing and Tooling

- Specs live in `spec/` and rely on RSpec with a dummy Rails app. Copy patterns from the admin controller/request specs to structure your own tests (`lib/generators/koi/admin_controller/templates/controller_spec.rb.tt`).
- Use `FactoryBot` factories shipped with the engine (`lib/koi/engine.rb:42` ensures they load when FactoryBot is present).
- To regenerate the dummy app in this repository, run `bundle exec thor dummy:install` (see `lib/tasks/dummy.thor`). This is primarily for engine development but illustrates how Koi expects host apps to be structured.

## Checklist For New Modules

The authoritative checklist lives in [`admin-module-workflow.md`](./admin-module-workflow.md). Use that guide for the full sequence (generating models, scaffolding admin modules, wiring navigation, adding authorisation/tests, and smoke-testing the UI). Keep this user guide handy for background context while the workflow guide drives the implementation steps.

---

Koi delivers a ready-made administrative experience that stays out of your domain logic. Once the engine is installed, lean on the generators, helpers, and Stimulus controllers described above to create consistent, maintainable admin interfaces for every client build.
