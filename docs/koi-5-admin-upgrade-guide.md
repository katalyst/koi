# Koi 5 Admin Upgrade Guide

## Purpose

Use this guide to upgrade legacy admin modules to Koi 5 while preserving product behavior and reducing drift.

## Preflight checklist

- Ensure the app and admin shell both load (`https://localhost`, `https://localhost/admin`).
- Install required engine migrations and migrate before feature work.
- Confirm admin CSS is pure CSS (Koi 5), not Sass-based admin entrypoints.
- Create a baseline checkpoint commit before module-by-module uplift.

## Module archetype: decide first

Pick lifecycle semantics before touching controller/view code.

- `Simple CRUD` (eg project types, industries): no lifecycle state; optional ordering.
- `Archivable` (eg staff, clients): boolean lifecycle with `archive/restore`; optional archived index.
- `Content stateful` (eg articles, pages, case studies): `publish/unpublish` via content state (`draft_version_id` / `published_version_id`).

Do not mix archetypes inside one module unless there is a strong product reason.

## Canonical module workflow

1. Regenerate with `bin/rails generate koi:admin <model> --force`.
2. Fix routes first (dedupe generator inserts, correct collection/member actions, confirm helpers with `rails routes`).
3. Align controller shape to Koi 5:
   - locals-based rendering
   - `params.expect`
   - explicit collection actions
   - `:see_other` redirect semantics
4. Move defaults/business invariants to model + migration (not controller setup).
5. Rework views to Koi 5 patterns (header/actions, concise table rows, summary table where useful).
6. Update request specs to match intended behavior.
7. Run module specs, admin request specs, then full suite.
8. Checkpoint commit.

## Strong params: `expect` rules

`expect` is stricter than legacy `require(...).permit(...)` for repeated nested structures.

- Scalar arrays: `author_ids: []`
- Repeated nested hashes: `items_attributes: [[:id, :index, :depth]]`
- Single nested hash: `seo_metadatum_attributes: %i[id title description keywords _destroy]`

Do not translate repeated nested structures from `permit` without checking shape.

## View conventions

- Keep index pages concise; only high-signal fields for triage/navigation.
- Avoid images on index/archived unless operationally required.
- State-scoped pages should not show the state column.
- Prefer explicit path helpers and avoid polymorphic path indirection where readability suffers.
- Use plain submit buttons; avoid `form.admin_save` / `form.admin_delete` in new Koi 5 work.
- Keep `form_with` in `new`/`edit` and use shared fields partials (`_metadata_fields`) for common inputs.
- Keep custom sections (eg SEO) explicit in `edit`, not hidden behind option locals.
- In ERB, use parentheses for helper calls with arguments, especially helper calls that also take a block.

### Header action helpers

- Use header action links for lifecycle/destructive actions rather than form action buttons.
- `link_to_delete(record)` always issues a delete request and confirms by default.
- `link_to_archive_or_delete(record)` archives active records and only shows delete when already archived.
- For non-standard routes, pass an explicit `url:` to avoid polymorphic mismatch.

### Archivable table UX

- For Koi 5 archivable modules, include selection checkboxes on active and archived indexes.
- Provide bulk `archive` and bulk `restore` actions via table selection controls.

## Ordering rules

- Keep ordering on the active/current index only.
- Do not paginate orderable index pages.
- Paginate non-orderable archived pages by default.
- Keep ordering concerns separate from lifecycle actions.

## Content module strategy

Use a phased approach:

- `Phase A (top/tail)`: index/new/edit first.
- `Phase B (editor)`: show/update content editor workflow.

For show/update in content modules:

- Build editor with `Katalyst::Content::EditorComponent.new(container: record)`.
- Preserve commit semantics (`publish`, `save`, `revert`).
- Invalid update from show should return turbo editor errors with `:unprocessable_content`.

## Lifecycle migration safety

When converting legacy lifecycle models (eg `active` -> content state):

- Migrate data first to preserve intent (eg inactive -> unpublished).
- Then remove legacy columns/scopes/UI paths.
- Update frontend selectors/scopes so hidden records do not reappear.

## Admin CSS + content icons

- Koi 5 admin stylesheet is CSS (`@import url("koi/index.css")`).
- Content 3 icon overrides use `[data-icon="..."]`; old `value` / `data-item-type` selectors no longer work.
- Custom content icons should use `viewBox="0 0 16 16"` and `stroke-width="2"`.

## Testing guidance

- Use tight request-spec loops while upgrading each module.
- Keep tests focused on app behavior, not Katalyst Tables internals.
- Avoid query-specific table tests like "finds needle" / "hides chaff".
- Use combined redirect assertions: `have_http_status(:see_other).and(redirect_to(...))`.

## Done criteria for one module

- Routes/helpers are correct and non-duplicated.
- Lifecycle behavior matches selected archetype.
- Index/show/edit UX follows Koi 5 conventions.
- Strong params `expect` shape is correct (especially repeated nested attributes).
- Module request specs pass.
- Admin request suite passes.
- Full suite passes (excluding known pending tests).

## References

- Koi controller patterns: `koi/app/controllers/admin/admin_users_controller.rb`, `koi/app/controllers/admin/url_rewrites_controller.rb`
- Koi views: `koi/app/views/admin/admin_users/index.html.erb`, `koi/app/views/admin/admin_users/archived.html.erb`
- Real-world archive/order pattern: `frg/app/controllers/admin/merchandise_controller.rb`, `frg/app/views/admin/merchandise/index.html.erb`
- Content editor contract: `koi/docs/skills/content-admin.md`
- Local upgrade examples in this repo:
  - `kat/app/controllers/admin/staff_controller.rb`
  - `kat/app/controllers/admin/articles_controller.rb`
  - `kat/app/controllers/admin/pages_controller.rb`
  - `kat/app/controllers/admin/case_studies_controller.rb`
