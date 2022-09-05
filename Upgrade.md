# Breaking changes and Upgrade Paths

## Next release

 * Requires Rails 7/Ruby 3
 * remove `//= link koi.js` from sprockets manifest, this is no longer required

## 2.7.0

 * Added stimulus and inputmaps as dependencies, no configuration changes required
 * Removed `:nice_tags` input type – functionality has been integrated with `:tags`

## 2.6.0

 * Added `Koi::ApplicationModel` for consistency with Rails Engine defaults. Extend this class for `has_crud` etc.
 * Replace references to Admin model class with AdminUser
 * Rename javascript and stylesheet entry points
   * In `app/assets/config/manifest.js`:
     * Replace `//= link koi/manifest.js` with `//= link koi.js` (Sprockets 4)

## 2.5.0

All Koi model and controller functionality was previously included automatically into ActiveRecord::Base and 
ActionController::Base by Koi. Now, you must manually include the functionality you want. 

### Admin controller functionality

    include HasCrud::ActionController
    include ExportableController

or, extend Koi::AdminCrudController

### Model functionality

    include HasCrud::ActiveRecord
    include Exportable
    include HasSettings
    include HasNavigation

or, to include all Koi model functionality

    include Koi::Model

### Dragonfly

The default dragonfly initializer has been modified. Apps must define their own dragonfly config.

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
