# Breaking changes and Upgrade Paths


## 4.0

- Removed front-end views from Koi so that controllers inheriting from Koi::CrudController 
  will no longer render views by default, and will need views in the app itself. This makes it clear that
  developers should be making decisions for themslves as to how their content should be rendered. 
- Removed default pagination from front-end controllers. If pagination is required it should be configured
  as needed.
 

## 3.3.0

Instead of nesting composable data in groups, composable data can now be stored
in named jsonb fields. See `Page` for an example.

Composable data fields are now configured directly, rather than via crud admin,
as these configurations are relevant to rendering as well as editing.

Prior versions of Koi had a bug where composable data was stored as a string
even if the field was a jsonb field. Upgrading will require a manual migration
to convert from strings to json. If you are upgrading from 3.1.2 or earlier, the
format of the `composable_data` field has not otherwise changed, but if you are
upgrading from 3.1.3 or later, you will need to split composable_data groups up
into separate fields.

## 2.2.1

* Removed `:images` from settings
* If the page model was customisd in the project, you will need to add `navigation: true` to the page model:

```ruby
  has_crud paginate: false, navigation: true,
           settings: true
```

And add some methods to allow it to be added to the sitemap:

```ruby
  # overriding has_navigation methods to work with koi page route namespacing
  def self.get_new_admin_url(options={})
    Koi::Engine.routes.url_helpers.new_page_path(options)
  end

  def get_edit_admin_url(options={})
    Koi::Engine.routes.url_helpers.edit_page_path(self, options)
  end
```

## 2.2.0

* Updated Koi::Menu.items format to use a nested format like:

```ruby
Koi::Menu.items = {
  "Modules": { ... },
  "Advanced": { ... }
}
```
