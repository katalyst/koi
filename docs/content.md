# Working With Koi Content

## Overview
Koi ships with the [Katalyst::Content] engine to deliver block-based, draftable page content. It gives editors a drag-and-drop authoring surface, versioning (draft/publish/revert), media-rich blocks, and theme-aware rendering, all inside the familiar Koi admin experience. Typical use cases include:

- marketing or landing pages that need reusable layouts without code changes;
- knowledge bases or documentation hubs where editors publish revisions safely;
- feature pages that mix text, media, and tabular data while respecting site branding.

Because the engine is mounted under `/admin/content`, Koi automatically loads the Stimulus controllers, styles, and error components the editor requires. Once a model opts-in to `Katalyst::Content::Container`, Koi’s admin controllers and helpers provide an end-to-end UI for drafting, previewing, and publishing content.

### Authoring Experience
From an editor’s perspective the content screen provides:

- **Block library** – layouts (sections, groups, columns, asides) and content blocks (rich text, figures, tables) are available from the “Add item” dialog or inline insert handle.
- **Tree + drag-and-drop** – reorder, indent, collapse, or remove blocks with guard rails supplied by the rules engine (e.g. only layout blocks can contain children).
- **Inline previews** – open any block in a modal form to edit fields; tables offer a WYSIWYG grid, and figures support direct uploads.
- **Draft workflow** – the status bar shows published/draft state and surfaces `Save`, `Publish`, `Revert`, and `Discard` buttons. Unsaved edits flag the status as “Unsaved changes”.
- **Safe publishing** – publishing promotes the draft version to live content, while revert snaps back to the last publication. Hidden blocks stay out of the frontend until re-enabled.

## Workflow: Adding Content To A Module (Pages Example)
This walkthrough assumes you already have a `Page` model with title/slug attributes and an admin module scaffolded in Koi.

1. **Install migrations**
   - run `bin/rails katalyst_content:install:migrations`
   - apply the generated migrations plus the Page-specific version table:
     ```ruby
     class CreatePageVersions < ActiveRecord::Migration[7.0]
       def change
         create_table :page_versions do |t|
           t.references :parent, null: false, foreign_key: { to_table: :pages }
           t.json :nodes
           t.timestamps
         end

         change_table :pages do |t|
           t.references :published_version, foreign_key: { to_table: :page_versions }
           t.references :draft_version,     foreign_key: { to_table: :page_versions }
         end
       end
     end
     ```
   - **Verification:** `bin/rails db:migrate` succeeds and `rails db:schema:dump` shows `katalyst_content_items` plus `page_versions` and the extra foreign keys on `pages`.

2. **Update the model**
   ```ruby
   # app/models/page.rb
   class Page < ApplicationRecord
     include Katalyst::Content::Container

     class Version < ApplicationRecord
       include Katalyst::Content::Version
     end
   end
   ```
   - **Verification:** `bin/rails console` – instantiate a page (`page = Page.new`) and set an items payload (`page.items_attributes = []`). `page.draft_version` should now return a version object, while `page.publish!` still raises because nothing is persisted yet. Assigning `items_attributes` (even an empty array) mimics the editor’s requests and is required before the container builds versions.

3. **Expose content in the admin controller**
   Adapt your admin controller to match the dummy implementation:
   ```ruby
   class Admin::PagesController < Admin::ApplicationController
     helper Katalyst::Content::EditorHelper

     def show
       page   = Page.find(params[:id])
       editor = Katalyst::Content::EditorComponent.new(container: page)
       render locals: { page:, editor: }
     end

     def update
       page = Page.find(params[:id])
       page.attributes = page_params

       unless page.valid?
         editor = Katalyst::Content::EditorComponent.new(container: page)
         respond_to do |format|
           format.turbo_stream { render editor.errors, status: :unprocessable_entity }
         end
         return
       end

       case params[:commit]
       when "publish" then page.save! && page.publish!
       when "revert"  then page.revert!
       else                  page.save!
       end

       redirect_to [:admin, page], status: :see_other
     end

     private

     def page_params
       params.expect(page: [:title, :slug, { items_attributes: [%i[id index depth]] }])
     end
   end
   ```
   - **Verification:** open `/admin/pages/:id` in a browser; the status bar should render and the add-item dialog should function. Submitting invalid data should render the inline error frame supplied by `Koi::Content::Editor::ErrorsComponent`.

4. **Render the editor in the view**
   ```erb
   <!-- app/views/admin/pages/show.html.erb -->
   <%= render editor.status_bar %>

   <%= render editor do |editor_component| %>
     <% editor_component.with_new_items do |component| %>
       <h3>Layouts</h3>
       <ul role="list" class="items-list">
         <%= component.item(:section) %>
         <%= component.item(:group) %>
         <%= component.item(:column) %>
         <%= component.item(:aside) %>
       </ul>
       <h3>Content</h3>
       <ul role="list" class="items-list">
         <%= component.item(:content) %>
         <%= component.item(:figure) %>
         <%= component.item(:table) %>
       </ul>
     <% end %>
   <% end %>
   ```
   - **Verification:** refreshing the page should show the grouped block library; dragging blocks should update the tree without validation errors.

5. **Expose frontend rendering**
   - In public controllers use `render_content(page.published_version)` (or `draft_version` for previews).
   - Ensure your frontend layout imports `/katalyst/content/frontend.css` if you are not already using Koi’s defaults.
   - Add a standard show/preview route so the editor status bar can link to the live and draft versions:

     ```ruby
     # config/routes.rb
     resources :pages, only: :show do
       get :preview, on: :member
     end

     # app/controllers/pages_controller.rb
     class PagesController < ApplicationController
       helper Katalyst::Content::FrontendHelper

       before_action :set_page

       def show
         render locals: { page: @page, version: @page.published_version || fallback_version }
       end

       def preview
         render :show, locals: { page: @page, version: @page.draft_version || fallback_version }
       end

       private

       def set_page
         scope = action_name == "preview" ? Page.with_archived : Page.not_archived
         @page = scope.find(params[:id])
       end

       def fallback_version
         @page.draft_version || @page.build_draft_version
       end
     end
     ```

   - **Verification:** visit the public page and confirm blocks render respecting heading styles, themes, and visibility toggles. The status bar’s “Published/Preview” links should now resolve without overrides.

## Built-in Content Types
Koi registers the default block set from the engine (`Katalyst::Content.config.items`):

| Block | Purpose |
| --- | --- |
| `Section` | Top-level layout with heading + child flow. |
| `Group` | Secondary grouping container. |
| `Column` | Two-column wrapper; splits children between columns. |
| `Aside` | Content + sidebar layout with optional mobile reversal. |
| `Content` | Rich-text body via Action Text (supports attachments). |
| `Figure` | Image with alt text and optional caption; enforces file type/size limits. |
| `Table` | Sanitised HTML table with heading row/column helpers and toolbar for paste/clean-up. |

To extend the library:

1. Create a subclass of `Katalyst::Content::Item` (or `Layout`) with any custom attributes via `style_attributes` and partials under `app/views/katalyst/content/<type>/`.
2. Append the class name to `Katalyst::Content.config.items` (typically in an initializer) so the editor exposes it in the block picker.
3. Provide a form partial (`_your_type.html+form.erb`) and a render partial (`_your_type.html.erb`).

A follow-up document will dive deeper into block authoring and theming.

## Internals & Reference (for Humans and LLM Agents)
This section summarises the architecture uncovered during investigation. It is intentionally explicit so maintainers and coding agents can script changes safely.

- **Data model**: `katalyst_content_items` stores polymorphic blocks. Containers keep draft/published foreign keys and delegate to `Version` models that serialise `{id, depth, index}` nodes through `Katalyst::Content::Types::NodesType`. Garbage collection (`Content::GarbageCollection`) removes stale versions and items two hours after they fall out of active drafts.
- **State machine**: The `Container` concern derives `state` (`unpublished`, `draft`, `published`) from whether draft/published references match. `publish!` replaces the published pointer with the current draft; `revert!` resets drafts back to published; `unpublish!` clears publication altogether.
- **Editor stack**: `EditorComponent` assembles the form, status bar, block table, and `new_items` slot. `Editor::TableComponent` wraps the block list with Stimulus controllers (`content--editor--list`, `content--editor--container`) to handle drag/drop and structural updates. Turbo frames (`content--editor--item-editor`) host block forms, and errors render through `Katalyst::Content.config.errors_component` (overridden by Koi to use `Koi::FormBuilder`).
- **Stimulus controllers**: Found under `content/app/javascript/content/editor/`. Key controllers include `container_controller` (tree state, rule enforcement), `rules_engine` (validation + permission toggles), `item_editor_controller` (modal lifecycle), `table_controller` (contenteditable facade for tables), and `trix_controller` (Action Text compatibility patch).
- **Routes & controllers**: Engine routes expose `items` and `tables` resources plus `direct_uploads#create`. `ItemsController` dynamic-dispatches permitted params based on `config.items`, duplicates records on update to keep history, and pre-saves attachments to avoid data loss when validations fail.
- **Rendering helpers**: `render_content(version)` groups visible items by theme, wraps them in `.content-items` with data attributes (`content_item_tag`), and caches by version record. Layout partials call back into `render_content_items` for child trees.
- **Configuration hooks**: `Katalyst::Content.config` influences available themes, heading styles, block classes, max upload size, table sanitiser allow-list, and which error component/controller base to use. Koi’s engine initializer sets `base_controller` to `Admin::ApplicationController` and swaps the error component to Koi’s GOV.UK-flavoured implementation.
- **Testing surface**: The engine ships a dummy app demonstrating the full integration (`spec/dummy/app/...`) and extensive model specs for blocks and container behaviour. When automating changes, follow the patterns in `spec/models/page_spec.rb` to assert version transitions and item validation.

Use this reference when automating editor customisations, generating documentation, or writing migrations—each bullet maps to concrete files in the `content/` engine, making it safe for agents to reason about entry points.
