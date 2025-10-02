# Archiving Modules in Koi

Use this guide whenever you scaffold or retrofit a module that supports soft deletion via `archived_at`. It summarises the conventions baked into Koi, the gaps left by generators, and the post-generation steps required to give editors a predictable UI.

## What the Generators Provide

When the schema contains an `archived_at` column _and_ the model mixes in `Koi::Model::Archivable` (add the concern before running `koi:admin`, or rerun the generator afterward so it picks up the capability):

- `koi:model` keeps `archived_at` in the migration but, as of Koi 5.0.3, does **not** insert `include Koi::Model::Archivable`; add the concern manually (before running `koi:admin`) so the admin generator can detect the capability.
- `koi:admin` generates:
  - Bulk archive tooling on the index (`table_selection_with` + `Archive` button) and an `Archived` tab.
  - Controller actions `archive`, `restore`, and `archived`, plus the `destroy` behaviour that archives first, then hard-deletes once already archived.
  - Routes and menu entries for the additional actions.
- Default scopes become `not_archived`, so new records stay visible unless explicitly archived.

## What You Still Need to Wire Manually

1. **Permit the toggle** – add `:archived` to strong parameters in the admin controller so the form checkbox can post back:
   ```ruby
   def page_params
     params.expect(page: [
       :title,
       :published_on,
       :archived_at,
       :archived,
       { items_attributes: [%i[id index depth]] },
     ])
   end
   ```

2. **Expose the checkbox** – surface the boolean on both new/edit forms so editors can archive or restore a single record without navigating away:
   ```erb
   <%= form.govuk_check_box_field :archived %>
   ```
   The concern maps the boolean to the soft-delete helper (`true` ⇒ archive, `false` ⇒ restore). Because new records default to unchecked, they start unarchived.

3. **Surface state in the UI** – include `row.boolean :archived` (or `:archived?`) in summary tables so admins can see the flag on the show screen. This is optional but recommended for clarity.

4. **Tests** – extend the request spec to cover:
   - Bulk archive & restore actions (`PUT /archive`, `PUT /restore`).
   - Destroy behaviour (archives first, then deletes when already archived).
   - Form-driven archiving via the checkbox on create/update.
   Use `Page.archived` / `Page.not_archived` to assert state changes.

5. **Content status bar links** – if the module uses Katalyst::Content, make sure you expose matching public routes so the editor’s status bar can link to the live and preview versions. Add something like:
   ```ruby
   resources :pages, only: :show do
     get :preview, on: :member
   end
   ```
   Then render the published/draft versions in a controller (`render_content(page.published_version)` / `page.draft_version`) so `url_for(container)` resolves correctly. Without these routes, the status bar raises “undefined method `page_path`” and its links break.
   If the site needs `/slug` URLs without the `/pages` prefix, layer on the constraint workflow in [`root-level-page-routing.md`](./root-level-page-routing.md).

## Typical Admin Workflow

1. **Archive from the index** – select rows using the checkboxes, click `Archive`, confirm the toast, and verify they disappear from the active index.
2. **Restore from the archived tab** – open `Archived`, select records, click `Restore`.
3. **Archive from the form** – open a record, tick “Archived”, save. The index removes it (default scope). Editing again and unticking restores it.
4. **Permanent delete** – once a record is archived, hitting the destroy action (via index bulk delete or form archive again) removes it entirely.

## Recommended Follow-up Checks

- Ensure the menu entry still surfaces the module under `Koi::Menu.modules`.
- If the module exposes public routes, verify archived records fall out of default public scopes (because of the default scope).
- Run `bundle exec rspec` for the request specs touching archive flows.

Keep this guide close when adding new archivable modules so future changes stay consistent with Koi’s soft-delete semantics.
