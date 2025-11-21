# Root-Level Page Routing

## Overview
Use this pattern when editors manage marketing or CMS pages in Koi but expect URLs like `/about-us` or `/contact` instead of `/pages/about-us`. The pattern combines a route constraint, a resolver, and controller helpers so:

- the router keeps page slugs at the top level without colliding with other resources;
- `PagesController::Constraints` decides whether to serve the request (published pages for the public, drafts for admins via preview);
- the matched page is cached on the Rack request (`katalyst.matched.page`) so subsequent lookups (including SEO helpers) reuse it;
- URL helpers such as `page_path(page)` resolve correctly because of the custom `resolve("Page")` declaration.

## Common Use Cases

- Marketing sites where `Page` records powered by Katalyst Content should render at the root path.
- Landing pages that need draft previews behind admin authentication without leaking unpublished content.
- Projects with a single CMS-backed module that owns the remaining slug space (e.g. `Pages`, `Articles` when everything else lives under `/admin` or namespaced routes).

Although the implementation is reusable, confirm there is only one module expected to match arbitrary root slugs; multiple modules using the same technique would compete for every unknown path.

## Routing Setup

Add the constraint block near the end of your public routes (after any explicit top-level paths that must win):

```ruby
constraints PagesController::Constraints do
  resources :pages, path: "", only: [:show], param: :slug, constraints: { format: :html } do
    get :preview, on: :member
  end
end

resolve("Page") { |page, options = {}| [:page, { slug: page.slug, **options }] }
```

Key details:

- `path: ""` removes the `/pages` prefix while still relying on `resources` wiring and helpers.
- The collection is read-only; only `show` and `preview` are exposed to avoid accidental mass routing.
- `constraints: { format: :html }` keeps JSON, RSS, and other formats available for other controllers.
- `resolve("Page")` ensures `polymorphic_path(page)` and friends generate the friendly slug rather than `/pages/:id`.

## Controller Responsibilities

The public controller handles lookups, previews, and SEO helpers while delegating gatekeeping to the inner constraint:

```ruby
class PagesController < ApplicationController
  helper Katalyst::Content::FrontendHelper

  def show
    render locals: { page:, version: page.published_version }
  end

  def preview
    return redirect_to action: :show if page.state == "published"

    render :show, locals: { page:, version: page.draft_version }
  end

  def seo_metadatum
    page.seo_metadatum
  end

  private

  def page
    if request.has_header?("katalyst.matched.page")
      request.get_header("katalyst.matched.page")
    else
      Page.find_by!(slug: params[:slug])
    end
  end

  class Constraints
    attr_reader :request

    def self.matches?(request) = new(request).match?

    def initialize(request)
      @request = request
    end

    def match?
      request.set_header("katalyst.matched.page", page)
      return false if page.blank?

      case action
      when "show"   then page.published?
      when "preview" then admin?
      else false
      end
    end

    def action = request.params[:action]

    def admin? = request.session[:admin_user_id].present?

    def page
      return unless request.params[:slug] && request.get?
      @page ||= Page.find_by(slug: request.params[:slug])
    end
  end
end
```

Highlights:

- The constraint only runs for GET requests with a `slug` param, letting other verbs fall through.
- Matched pages are cached on the request, so the controller, SEO helpers, and downstream services (e.g. layout components) share one lookup.
- `match?` returns `false` when no page is found or when a non-admin requests a preview, letting the router continue to the next route.
- `admin?` piggybacks on the `admin_user_id` session that Koi already sets when an admin is signed in.
- `preview` redirects to `show` when the page is already published, ensuring canonical URLs.
- The `seo_metadatum` pass-through demonstrates how additional controller actions can reuse the cached page without hitting the database again.

## Implementation Checklist

- **Confirm requirements** – when a feature request mentions a “Pages” model, ask whether top-level slugs are expected. Default to this pattern when the answer is yes.
- **Slug uniqueness** – ensure the `pages` table validates and indexes `slug` uniqueness; otherwise collisions produce confusing fallbacks.
- **Route ordering** – keep explicit static routes (`get "/health"`) above the constraint block. Anything defined below may never run because the constraint claims the slug first.
- **Preview access** – verify that admin authentication is in place (via `Koi.config.authenticate_local_admins` or real login) before relying on previews.
- **Caching hooks** – if you add middleware or helpers that assume `request.page`, use the header set in `match?` to avoid duplicate queries.
- **Specs** – cover `GET /:slug` for published pages, `GET /:slug/preview` for admins, and missing slugs falling through to a 404.

## Extending Beyond Pages

This approach works for any single module that owns the remaining root paths—swap `Page`/`PagesController` for your model/controller pair. Before doing so:

- confirm no other module needs arbitrary root slugs (otherwise introduce a namespace or prefix to avoid ambiguity);
- adjust the constraint’s `admin?` and visibility checks to match the module’s publication workflow;
- update `resolve("ModelName")` accordingly so polymorphic helpers stay correct.

If you genuinely need multiple modules sharing the root namespace, consider a dispatcher that inspects the slug format or a database-backed router instead of duplicating this constraint class.

