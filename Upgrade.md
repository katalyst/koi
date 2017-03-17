# Breaking changes and Upgrade Paths

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
