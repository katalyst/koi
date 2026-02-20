# Skill: Content Admin (Existing Model)

Use this guide when adding Katalyst Content editing to an already-existing admin resource in a Koi app.

This is the canonical v3 pattern the planned content-admin generator should produce.

## Scope

- Existing model only (hard requirement).
- Targets `katalyst-content` v3 behavior.
- Focuses on admin CRUD + editor wiring, not frontend page rendering.

## Generator Contract Checklist

Use this as the short, testable contract for generator templates and generator specs.

1. **Controller helper and editor wiring**
   - Generated controller includes `helper Katalyst::Content::EditorHelper`.
   - `show` builds `Katalyst::Content::EditorComponent.new(container: resource)`.

2. **Strong params include content tree**
   - Generated params include `items_attributes: [%i[id index depth]]`.

3. **Create builds initial draft**
   - Successful `create` calls `build_draft_version` and persists it.

4. **Update supports content workflow commits**
   - Handles `commit` values: `publish`, `save`, `revert`.

5. **Update invalid from show renders turbo errors**
   - Invalid update path can render `editor.errors` with `:unprocessable_content` for turbo stream requests.

6. **Bulk publish/unpublish actions exist**
   - Generated controller includes collection `publish` and `unpublish` actions.
   - Generated routes include matching collection endpoints.

7. **Views include editor shell on show**
   - `show.html.erb` renders `editor.status_bar` and `render editor`.

8. **Expected template set exists**
   - Generated views include: `index`, `show`, `new`, `edit`, and fields partial.

9. **Force overwrite supported for upgrades**
   - Generator supports force-overwrite workflows for upgrade diffing.

10. **Existing model only guard**
    - Generator does not create model/migration files.

## Style expectations

- Use parentheses for method calls with multiple arguments.
- In views, use parentheses for helper calls that take arguments, including calls that take a block.
- In DSL-style Ruby code (for example request-spec `get/post/patch` flows), omitting parentheses is acceptable when it reads more clearly.
- In request specs, prefer combined redirect assertions:
  - `expect(response).to have_http_status(:see_other).and(redirect_to(...))`

## Prerequisites

Before wiring actions/views, confirm all of the following.

1. **Gem version**
   - App is on `katalyst-content` v3.
   - Verify in `Gemfile.lock`.

2. **Model setup**
   - Model includes `Katalyst::Content::Container`.
   - Nested `Version` model includes `Katalyst::Content::Version`.
   - Model has `draft_version_id` and `published_version_id` references.

   Example:

   ```ruby
   class Page < ApplicationRecord
     include Katalyst::Content::Container

     class Version < ApplicationRecord
       include Katalyst::Content::Version
     end
   end
   ```

3. **Admin base controller**
   - Resource controller inherits from your admin base (typically `Admin::ApplicationController`).
   - Admin base includes Koi controller concerns.

4. **Content editor mount/config**
   - Content engine is mounted under admin scope (Koi default: `/admin/content`).
   - Koi content initializer behavior is active (`base_controller`, errors component).

5. **Resource routing shape**
   - Decide whether resource lookup is by `id` or `slug`.
   - Keep this consistent in controller, routes, and link helpers.

6. **Display identity**
   - Model implements meaningful `to_s` (for headers, breadcrumbs, links).

## Expected Actions

The resource controller should expose these actions and behavior.

### `index`

- Render standard admin collection/list view.
- Include bulk publish/unpublish actions when supported by routes.

### `show`

- Build editor with `Katalyst::Content::EditorComponent.new(container: record)`.
- Render locals with both record and editor.

### `new` / `edit`

- Render metadata form only (title/slug/etc), not the content tree.
- For project-specific metadata concerns (for example SEO), build nested data before rendering edit.

### `create`

- Build and save resource from strong params.
- On success, create the initial draft:
  - `record.build_draft_version`
  - `record.save!`
- Redirect to admin show.
- On failure, render `:new` with `:unprocessable_content`.

### `update`

- Assign params first (`record.attributes = ...`).
- If invalid:
  - If request came from `show`, return turbo-frame errors from `editor.errors`.
  - If request came from `edit`, render `:edit` with `:unprocessable_content`.
- If valid, branch by submit intent:
  - `publish`: `save!` then `publish!`
  - `save`: `save!`
  - `revert`: `revert!`
- Redirect back to show (or back to previous page) using existing app convention.

### `publish` / `unpublish`

- Collection actions updating selected ids:
  - `publish!` for each selected record.
  - `unpublish!` for each selected record.
- Redirect to index with `:see_other`.

### `destroy`

- If currently published: unpublish and redirect to edit.
- Else: destroy and redirect to index.

## Controller Example

Adapt this to your resource naming and lookup strategy:

```ruby
# app/controllers/admin/pages_controller.rb
module Admin
  class PagesController < ApplicationController
    helper Katalyst::Content::EditorHelper

    before_action :set_page, only: %i[show edit update destroy]

    def show
      editor = Katalyst::Content::EditorComponent.new(container: page)
      render(locals: { page:, editor: })
    end

    def create
      @page = Page.new(page_params)

      if page.save
        page.build_draft_version
        page.save!
        redirect_to(admin_page_path(page), status: :see_other)
      else
        render(:new, locals: { page: }, status: :unprocessable_content)
      end
    end

    def update
      page.attributes = page_params

      unless page.valid?
        case previous_action
        when "show"
          editor = Katalyst::Content::EditorComponent.new(container: page)
          return respond_to do |format|
            format.turbo_stream { render(editor.errors, status: :unprocessable_content) }
          end
        when "edit"
          return render(:edit, locals: { page: }, status: :unprocessable_content)
        end
      end

      case params[:commit]
      when "publish"
        page.save!
        page.publish!
      when "save"
        page.save!
      when "revert"
        page.revert!
      end

      if previous_action == "edit"
        redirect_to(admin_page_path(page), status: :see_other)
      else
        redirect_back_or_to(admin_page_path(page), status: :see_other)
      end
    end

    def publish
      Page.where(id: params.expect(id: [])).each(&:publish!)
      redirect_back_or_to(admin_pages_path, status: :see_other)
    end

    def unpublish
      Page.where(id: params.expect(id: [])).each(&:unpublish!)
      redirect_back_or_to(admin_pages_path, status: :see_other)
    end

    def destroy
      if page.published?
        page.unpublish!
        redirect_to(edit_admin_page_path(page), status: :see_other)
      else
        page.destroy!
        redirect_to(admin_pages_path, status: :see_other)
      end
    end

    private

    attr_reader :page

    def set_page
      @page = Page.find_by!(slug: params.expect(:slug))
    end

    def previous_action
      previous = request.referer&.split("/")&.last
      %w[show edit].include?(previous) ? previous : "show"
    end

    def page_params
      return {} if params[:page].blank?

      params.expect(page: [:title, :slug, { items_attributes: [%i[id index depth]] }])
    end
  end
end
```

## Expected Views

At minimum, generate and maintain these templates:

- `index.html.erb`
- `show.html.erb`
- `new.html.erb`
- `edit.html.erb`
- `_fields.html.erb` (or `_form_fields.html.erb`, project convention)

### `show.html.erb`

`show` is where content editing lives. It should render the status bar and editor shell.

```erb
<%# locals: (page:, editor:) %>

<%= render(editor.status_bar) %>
<%= render(editor) do |editor_component| %>
  <% editor_component.with_new_items do |component| %>
    <h4>Content</h4>
    <ul role="list" class="items-list">
      <%= component.item(:content) %>
      <%= component.item(:figure) %>
    </ul>

    <h4>Layout</h4>
    <ul role="list" class="items-list">
      <%= component.item(:section) %>
      <%= component.item(:group) %>
      <%= component.item(:column) %>
      <%= component.item(:aside) %>
    </ul>
  <% end %>
<% end %>
```

Notes:

- The item palette is intentionally project-specific.
- Keep group headings and ordering explicit so upgrades are easy to diff.

### `new` / `edit`

- Render metadata fields only.
- Keep the form actions focused on saving form content (plain submit button).
- Place non-form actions (for example view/preview/delete/unpublish) in the page header actions section.
- Keep content tree editing in `show`.

### Header action link helpers

Use Koi header helpers for destructive/lifecycle links in page-header actions.

- `link_to_delete(record)`
  - Renders a delete link for persisted records.
  - Uses `turbo_method: :delete` with a confirmation prompt by default.
  - Override URL when polymorphic admin paths are not correct for the module.

- `link_to_archive_or_delete(record)`
  - For archivable models only (`record` must respond to `archived?`).
  - If record is active, renders an **Archive** action.
  - If record is already archived, renders a **Delete** action with confirmation.

Example:

```erb
<% content_for :header do %>
  <%= actions_list do %>
    <li><%= link_to("View", page_path(page), target: "_blank") %></li>
    <li><%= link_to_archive_or_delete(page) %></li>
  <% end %>
<% end %>
```

### `index`

- Include search/query + table list.
- Include bulk publish/unpublish buttons when routes/actions exist.
- Include state column where available.
- For archivable modules, include row selection with bulk archive/restore actions.

## Tests (First Draft)

Cover behavior with request specs first. These tests define the expected generator contract.

### Required request spec coverage

1. Auth protection for admin endpoints.
2. `GET show` renders editor UI.
3. `POST create` creates record and initial draft version.
4. `PATCH update` invalid from show returns turbo error frame (`:unprocessable_content`).
5. `PATCH update` with `commit=save` persists changes.
6. `PATCH update` with `commit=publish` publishes.
7. `PATCH update` with `commit=revert` reverts draft to published.
8. `PUT publish` collection action publishes selected records.
9. `PUT unpublish` collection action unpublishes selected records.
10. `DELETE destroy` unpublishes when published, destroys when unpublished.

### Example spec snippets

```ruby
describe "POST /admin/pages" do
  it "creates an initial draft version" do
    post admin_pages_path, params: { page: { title: "About", slug: "about" } }

    page = Page.find_by!(slug: "about")
    expect(response).to have_http_status(:see_other).and(redirect_to(admin_page_path(page)))
    expect(page.draft_version).to be_present
  end
end
```

```ruby
describe "PATCH /admin/pages/:slug" do
  it "returns inline editor errors for turbo requests" do
    page = create(:page, :with_content_draft, slug: "about")

    patch admin_page_path(page),
          params:  { page: { title: "" }, commit: "save" },
          headers: { "ACCEPT" => "text/vnd.turbo-stream.html" }

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("_errors")
  end
end
```

```ruby
describe "PATCH /admin/pages/:slug" do
  it "publishes when commit is publish" do
    page = create(:page, :with_content_draft)

    patch admin_page_path(page), params: { page: { title: page.title }, commit: "publish" }

    expect(response).to have_http_status(:see_other).and(redirect_to(admin_page_path(page)))
    expect(page.reload).to be_published
  end
end
```

## Force Regeneration Workflow

Force-overwrite is expected for upgrade diffs.

1. Re-run generator with force enabled.
2. Review generated diff against current implementation.
3. Keep canonical controller/view contracts from this skill.
4. Re-apply project-specific customizations (item palette, custom fields, headers).
5. Run request specs and a manual content editor smoke test.

This keeps upgrades intentional while preserving local behavior where it is deliberately custom.
