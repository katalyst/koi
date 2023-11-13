2.6.6 / 2022-12-12
==================

* Adds rails 7.1 support
* Fix for missing protect_from_forgery in Koi::ApplicationController

2.6.4 / 2022-07-13
==================

* Fix specs
* Fix for rendering document thumbnails

2.6.3 / 2022-07-06
==================

* Fix for running rails without a database, for asset precompilation
* Fix for ruby 3 compatibility
* Added 'text' form field type

2.6.2 / 2022-06-15
==================

 * Fix fetching boolean Settings

2.6.1 / 2022-04-13
==================

 * Allow asset redirects in Rails 7 to redirect to CDN (allow_other_host: true)

2.6.0 / 2022-04-05
==================

 * Add base classes (Rails Engine Defaults)
 * Add specs and update dummy app to work with Rails 6
 * Add github actions
 * Deprecate DateHelper methods: use Rails i18n instead.
 * Deprecate HtmlHelper methods: these do not appear to be used.
 * Remove NavItem eval'd attributes: if, unless, highlights_on, content_block
   * Editing of these inputs has been disabled since v2.2.0
 * Rename Admin model class to AdminUser
   * Resolves Zeitwerk loading conflict with Admin module
 * Rename asset entry points, see [[Upgrade]] for details
   * Replace `//= link koi/manifest.js` with `//= link koi.js` (Sprockets 4)
   * `koi.js` => `koi/admin.js` (in admin layouts)
   * `koi/application.css` => `koi/admin.css` (in admin layouts)

2.5.3 / 2021-07-13
==================

* Update Fotorama.js to support alt and title image attributes

2.5.2 / 2021-07-08
==================

 * Upgrade Fotorama.css to v4.6.4

2.5.1 / 2021-06-30
==================

 * Adds rails 6 support
 * Removed generators and templates
 * Removed reports
 * Removed Garb
 * Removed uuidtools dependency
 * Removed activevalidators dependency
 * Removed htmlentities dependency
 * Removed pg dependency
 * Removed sidekiq, sidekiq-web, sinatra dependencies
 * Removed figaro dependency
 * Removed rails-observers dependency
 * Removed active_model_serializers dependency
 * Removed mime-types dependency
 * Removed redis dependency
 * Removed uglifier dependency
 * Removed countries dependency
 * Removed responders dependency
 * Removed sendgrid dependency
 * Removed auto included functionality, see Upgrade.md for details.

2.4 / 2020-08-04
==================

 * Fix HasNavigation failing to find Koi engine routes
 * Avoid duplicating default settings in database, requires manual step to clean
   up default settings from database:
       Translation.where(value: nil).delete_all
 * Fix `type: radio` in crud forms and show
       

1.1.0 / 13-02-2013
==================

  * Merge branch 'v1.0.0.beta' into v1.0.0
  * Added related products to product
  * Added views for product index and show
  * Added validation to almost all fields for products
  * Changed Assets image sizes, disabled orderable on category
  * Updated schema
  * Updated rails and rack versions due to a security fix
  * Updated rails and rack versions due to a security fix
  * Fixed form field partial
  * Added categories and products frontend
  * Modified products page
  * Updated category model formatting
  * Changed ruby 1.9.2 to 1.9.3
  * Added gemfile lock
  * Merge branch '1.0.0/ckeditor' into v1.0.0
  * Style properties surgery for CKEditor.
  * Merge pull request #50 from katalyst/1.0.0.beta/hotfix/nestedFields
  * Trim for HTML else jQ treats as expr.
  * Added basic changelog
  * Merge branch 'v1.0.0.beta' of github.com:katalyst/koi into v1.0.0.beta
  * Merge branch '1.0.0.beta/navigator' into v1.0.0.beta
  * Tifying up navigator.
  * Merge branch 'v1.0.0.beta' into 1.0.0.beta/navigator
  * Mergery.
  * Updated bowerbird_v2.
  * Revert "Replace partial lookup rescue blocks."
  * Merge branch 'v1.0.0.beta' of github.com:katalyst/koi into v1.0.0.beta
  * Merge branch 'v1.0.0.beta' into 1.0.0.beta/navigator
  * Updated things.
  * Merge pull request #46 from katalyst/change/pow
  * Added browser shim.
  * Added version file
  * Merge pull request #47 from katalyst/change/partial-lookups
  * Quick fix for link target.
  * Replaced media embedder.
  * Fixed tagify styles.
  * Fixed problem with nestedFields.
  * Source tidying.
  * Wysiwyg updates.
  * Tweaks.
  * CKEditor updates based on feedback.
  * Asset manager tweaks.
  * Editor tweaks.
  * Editor tweaks.
  * Merge branch '1.0.0.beta/jquery/1.9' into 1.0.0.beta/ckeditor
  * Added CKEditor back in.
  * Updated bbq.
  * Updated bowerbird_v2.
  * More space for wysiwyg dialogz.
  * Mergery.
  * Merge pull request #46 from katalyst/change/pow
  * Replace partial lookup rescue blocks.
  * Merge branch 'v1.0.0.beta' into change/pow
  * Add .powrc to the application template.
  * Merge pull request #44 from katalyst/1.0.0.beta/asset-scroll
  * Updated Rails to 3.2.11 to address a security issue
  * Added if and unless to navigational mutrex.
  * Hacky fix for scrolling in the asset manager.
  * Removed description object.
  * Editor layout fixes.
  * Merge branch 'v1.0.0.beta' into 1.0.0.beta/navigator
  * Merge branch '1.0.0.beta/editorial' into v1.0.0.beta
  * Removed unused Sections from core.
  * Merge branch 'v1.0.0.beta' into 1.0.0.beta/navigator
  * Removed pacecar as it was causing admin load issues
  * Merge branch '1.0.0.beta/dragonflew' into v1.0.0.beta
  * Allow twitter name to be used with jquery.tweet
  * Editor settings update.
  * Editor updates.
  * Fix for editor image resizing.
  * Revamped editor.
  * Better HTML cleanup for Wysiwyg.
  * Usability fixes for Wysiwyg.
  * Navigator fixes for bio strangeness.
  * Merge branch '1.0.0.beta/dragonflew' into 1.0.0.beta/navigator
  * Mergetastic.
  * Dragonfly introspection fix.
  * Admin style fix.
  * Added pacecar gem
  * Added pacecar gem
  * Added email validation to admin model
  * Added gem for extra validations
  * Updated google analytics embed key
  * Updated app generator to add sidekiq
  * Added sidekiq
  * Updated simple navigation gem
  * Updated simple navigation gem
  * Cleanup.
  * Added container class option to nav items
  * Updated outdated gems and changed friendly id slug to use to_s instead of titleize
  * Updated gitignore
  * Enabled page settings
  * Mergery.
  * Img wysiwyg fixywyg.
  * Editor fixes.
  * Style fix...
  * Another style fix.
  * Merge branch 'v1.0.0.beta' of github.com:katalyst/koi into v1.0.0.beta
  * Style tweaks for index.
  * Updated csv to handle all records
  * Added download CSV
  * Reverted the use of and instead of &&
  * Allow for full range of heading styles.
  * Fixed defined bug.
  * Added basic_file field type without any dragonfly support
  * Editor positioning balding process.
  * Style fixes for editor.
  * Removed cache dodger from wysi.
  * Wysi fix.
  * Editor fixes.
  * Added js localization.
  * Merge branch 'v1.0.0.beta' of github.com:katalyst/koi into v1.0.0.beta
  * Fix for js datepicker.
  * Removed last bits of wysihtml5.
  * Merge branch 'v1.0.0.beta' of github.com:katalyst/koi into v1.0.0.beta
  * Fixed admin labels to contain html
  * Asset link fix.
  * Modal menu asset manager links.
  * Assets menu and show link.
  * Force assets layout.
  * Wysi updates.
  * Wysi fixes.
  * Moar redactor fixes.
  * Fix for redactor controls.
  * Added missin sitemap js.
  * Wysiwyg additions.
  * Wysiwyg iframeability.
  * Reorganizing JS...
  * Editor hacking.
  * Modal setting width.
  * Fixing settings focus issue.
  * Fixing redactors handling of nesting.
  * No need to convert divs with current redactor patch.
  * Fixed tagify issue on backspace.
  * Tweak for contenteditable fix.
  * Fix for unfocusable webkit contenteditable within modal.
  * Asset path fix.
  * Added basic underline (poor icon).
  * Fix for dodgy tags, and allow for other tag field names.
  * Log statement left in.
  * Added scrollable modal with dynamic positioning.
  * Merge branch 'v1.0.0.beta' of github.com:katalyst/koi into v1.0.0.beta
  * Allow scripts in wysiwyg.
  * Changed frontend koi generator to create views by default
  * Changed default settings field type to rich text
  * Fixed settings creation method
  * Removed value validation from settings Now settings are created if they do not exists
  * Added missing devise layout to koi admin
  * Indents for redactor.
  * Air mode wysiwyg.
  * Fixed wysiwyg webkit paste error.
  * Fuzzy Rails version.
  * Typo.
  * Slug for assets.
  * Resizeability of wysiwyg images.
  * Asset Funk.
  * Getting wysiwyg to work with IE, bit of refactoring.
  * Getting wysiwyg to work with IE, bit of refactoring.
  * Plupload fallback.
  * Merge pull request #43 from katalyst/1.0.0.beta/feature/redactorjs
  * Working on plupload.
  * Fix the layout of module index pages in IE8.
  * Fixes for Garb.
  * Remove log statements.
  * SCSS fix.
  * Another wysifix.
  * wysiwyg fixes.
  * Tackling bootstrap to the ground, and punching it in the face repeatedly.
  * Overcoming bootstrap modal idiocy.
  * Overcoming bootstrap modal strangeness.
  * Updated to latest Koi.
  * Merge.
  * Added asset manager to redactor.
  * Removed redactor which was added by mistake
  * Fixed missing bootstrap variable error
  * Added redactorjs
  * More tag fixes.
  * Editor tweaks.
  * Editor tweaks.
  * wysiwyg parsing for iframes.
  * Proper hidden nav styleing.
  * CSS for hidden navitems.
  * Editor tweaks.
  * Merge pull request #41 from katalyst/1.0.0.beta/feature/upgrade-editor
  * Fixed block heading thingy.
  * Further tweaks/fixes for wysiwyg.
  * Editor changes.
  * Editor hacking.
  * Fixery of the editory.
  * Upgraded editor.
  * Added powrc for rvmrc to dummy.
  * Form field collection errors fix.
  * Style and dependency fixing.
  * Trying to fix.
  * Removed caching from sitemap.
  * Removed caching from sitemap.
  * Typo.
  * Typo.
  * Layout fixes for nested fields.
  * Helpers for wysi text.
  * Work.
  * Navigation.
  * Ironing.
  * Merge branch '1.0.0.beta/nav_item_optimisation' into 1.0.0.beta/jdr-v2
  * Working.
  * Merge branch '1.0.0.beta/nav_item_optimisation' into 1.0.0.beta/jdr-v2
  * Added some navigation generation methods.
  * Added sections model.
  * Fuzzy Rails version.
  * Updated Devise
  * Added belongs_to form field
  * Merge branch 'v1.0.0.beta' of github.com:katalyst/koi into v1.0.0.beta
  * Updated seeds
  * Merge pull request #38 from katalyst/1.0.0.beta/feature/banners
  * Added base settings creation
  * Disabled low level nav item caching
  * Added setting prefix for items which are not present in nav
  * Added cascaded setting and banner helpers
  * Added active_items renderer
  * Fixed menu item cascading
  * Updated simple navigation
  * Added images as settings field type
  * Merge pull request #37 from katalyst/1.0.0.beta/feature/settings
  * Fixed settings key, prefix uniqueness bug
  * Updated uniqueness index for translation table
  * Merge branch 'v1.0.0.beta' into 1.0.0.beta/feature/settings
  * Merge branch 'v1.0.0.beta' of github.com:katalyst/koi into v1.0.0.beta
  * Removed explicit factory_girl require
  * Fixed weird translation setting is_settable conflict
  * Updated main settings to only show non prefixed times
  * Enabled settings by default on all crud models
  * Merge pull request #36 from katalyst/1.0.0.beta/hotfix/editor
  * Removed CKEDITOR.
  * Added settings lable to application layout
  * Added settings helper frontend
  * Fixed edit and destroy methods for settings
  * Refactored settings with a prefix column in translation table
  * Updated settings form
  * Merge branch 'v1.0.0.beta' into 1.0.0.beta/feature/settings
  * Added modal settings
  * Merge pull request #35 from katalyst/1.0.0.beta/bug/editor
  * Added basic settings tab to admin crud
  * Fixes for editor.
  * Resizing iframe for asset manager.
  * Tag highlighting and close button.
  * Asset manager environment state management utility branch eltron.
  * Merge branch 'v1.0.0.beta' into 1.0.0.beta/feature/settings
  * Merge pull request #33 from katalyst/1.0.0.beta/feature/help-cleanup
  * Merge pull request #34 from katalyst/1.0.0.beta/feature/caching
  * Updated admin sitemap navigation caching namespace
  * Changed ancestors touch to parent touch based on @haydn code review
  * Basic NavItem caching
  * Fix links to point to the help page instead of the old screencasts page.
  * Merge the screencasts and help pages.
  * Remove the unused "nav" view.
  * Removed pages admin menu link from application template
  * Merge pull request #32 from katalyst/1.0.0.beta/feature/layout-restructure
  * Move the admin navigation into a partial.
  * Merge pull request #31 from katalyst/1.0.0.beta/feature/application-template
  * Updated template to fix koi version
  * Added devise config and application whitelist config updates
  * Merge pull request #30 from katalyst/1.0.0.beta/feature/remove_exits_model
  * Removed exits unit test
  * Updated schema
  * Removed exits model and migration
  * Merge pull request #29 from katalyst/alex/navigation
  * Merge branch 'alex/navigation' of github.com:katalyst/koi into alex/navigation
  * Merged nav_item.
  * Merge pull request #15 from katalyst/documentation
  * Merge pull request #25 from katalyst/1.0.0.beta/feature/dashboard-analytics
  * Merge branch 'v1.0.0.beta' into 1.0.0.beta/feature/dashboard-analytics
  * Removed old exit analytics before filter
  * Minor refactoring and added organic searches metric
  * Merge pull request #27 from katalyst/feature/unassociated_assets
  * Merge pull request #26 from katalyst/1.0.0.beta/bug/forgot-password
  * Minor formatting
  * Merge pull request #23 from katalyst/feature/new-editor
  * Disabled password_salt from devise admin migration
  * Merge branch 'feature/new-editor' of github.com:katalyst/koi into feature/new-editor
  * Added wysywig gem to the app template
  * Filtering unassociated assets from asset index view.
  * Refactored and added create and find_or_create settings
  * Extracted settings into settings module
  * Basic Settings
  * Merge pull request #24 from katalyst/1.0.0.beta/feature/crud-headings
  * Improved insert link dialog for wysiwyg.
  * Updated gems and reverted form path.
  * Overwrote devise admin password controller Overwrote devise admin password mailer views
  * Merged beta.
  * Added document linker to asset manger.
  * Upgraded Devise
  * Changed normal i18n t method to customized kt
  * Added parent to admin titles, refactored
  * Added labels for metric elements
  * Added time formats initializer
  * Added Basic Dashboard based on Reports
  * Changing to title case rather than all uppercase
  * Added basic google analytics report
  * Updated Admin Crud Heading
  * Fixtyles.
  * Fix for sortable icon on general index.
  * Fixed sortable asset styles.
  * Slightly better close button for asset manager.
  * Merge branch 'master' into feature/new-editor
  * Added modal asset manager.
  * Merge pull request #21 from katalyst/feature/example-models
  * Merge branch 'v1.0.0.beta' into feature/example-models
  * Added friendly id codes to product and category
  * Merge pull request #20 from katalyst/feature/crud-cleanup
  * Added Google Analytics URL within the Dashboard
  * Merge pull request #18 from katalyst/font-update
  * refactor css for dashboard widgets
  * Made buttons semibold text
  * Merge pull request #17 from katalyst/font-update
  * Revert "minor tweaks"
  * Deleted old font
  * Font updated
  * Update the read me.
  * adding in sortable icon image
  * Merge pull request #14 from katalyst/1.0.0.beta/bug/koi-page-edit-redirect
  * Overwrote Koi Admin Pages Edit form Back Button
  * Merge pull request #13 from katalyst/1.0.0.beta/bug/change-password-should-log-out
  * Added Admin Authentication Check for all Koi Admin Actions
  * minor tweaks
  * Added sendgrid initializer
  * fixed up positioning of sortable icon for list
  * added categories and products nested models, added sortable icon back in, fixed is mobile checkbox layout
  * Merge branch 'v1.0.0.beta' into feature/crud-cleanup
  * adding glyficons and styling for dashboard (needs a refactor)
  * adding glyphicons, starting on the dashboard widget and cleaned up doctype
  * Merge pull request #9 from katalyst/1.0.0.beta/bug/items-per-page-highlight
  * Re-added id to a div that is used refresh items per page
  * Merge pull request #8 from katalyst/1.0.0.beta/bug/ajax-search
  * Added ajax search class selector to form
  * Fixed styles on asset manager.
  * Fixed super_hero user factory
  * minor cleanup of screen casts and sidebar text
  * Making stuff.
  * Merge pull request #7 from katalyst/1.0.0.beta/bug/admin-form-edit
  * Fixed form edit bug
  * various minor style tweaks and fix for ol,ul that broke the site tree
  * Merge branch 'v1.0.0.beta' of github.com:katalyst/koi into v1.0.0.beta
  * Updated pry
  * Merge branch 'v1.0.0.beta' of github.com:katalyst/koi into v1.0.0.beta
  * form tweaks and minor css cleanup
  * JQuery ui assets hook-up.
  * Added bootstrap-wysihtml5-rails gem.
  * Another dirty ckeditor CSS hack removed.
  * Another dirty ckeditor CSS hack removed.
  * Merge branch 'v1.0.0.beta' of github.com:katalyst/koi into v1.0.0.beta
  * Merge branch 'master' of github.com:katalyst/koi into v1.0.0.beta
  * Merge pull request #6 from katalyst/alex/site-tree-refactor
  * CK editor filter:; fix.
  * Clean up and properize.
  * Bumped Version
  * Refactoring the site-tree.
  * Removed nav_item folder movage restriction (temporary?).
  * Removed duplicate callback of $.fn.application.
  * Style fixes for index.
  * Removed offending articles from CSS causing SASS to complain.
  * Removed offending articles from CSS causing SASS to complain.
  * Fixed koi initializer controller load path in app template
  * Added bowerbird to app template
  * Merge branch 'develop' into v1.0.0.beta
  * Merged feature/mobile.
  * CKeditor fix.
  * Navigation for any nav_item.
  * added bootstrap-dropdown back in and cleaned up titlebar css
  * Updated gems.
  * disabled active item cascade
  * Changed is_mobile label
  * Added Pages Controller to Mobile
  * Added is_mobile to Nav
  * Added basic mobile layout
  * Sitemap styling.
  * Style fix.
  * Style fixes.
  * BS = BootStrap
  * Rebuild.
  * Fixes.
  * Rebuild.
  * Somewhere.
  * Naughty Knave.
  * Shuffle.
  * Added url to cascade
  * Updated help
  * Fixed Google Analytics seed
  * Added basic cascading NavigationHelper
  * Merge branch 'feature/bootstrap' of github.com:katalyst/koi into feature/bootstrap
  * Fixed i18n and simple form deperactions
  * Updated nested_set
  * Merge branch 'feature/bootstrap' of github.com:katalyst/koi into feature/bootstrap
  * another minor clean up
  * Added screencast page
  * Added checkbox wrapper
  * Merge branch 'feature/bootstrap' of github.com:katalyst/koi into feature/bootstrap
  * Modal close button is working now
  * last cleanup of style sheets... for the moment
  * cleaning up front end css
  * more cleaning up unused css files
  * removing css files and added in boolean field
  * minor tweaks - cleaned up orange colours and removed titlebar css
  * moved external js into 'external' folder and cleaned up styling for site settings
  * tagify clean up and moved external css into folder called 'external'
  * login form tweaks
  * Merge branch 'feature/bootstrap' of github.com:katalyst/koi into feature/bootstrap
  * clean up of login / fogot password
  * Fixed asset manager insert links
  * Added rvmrc file to the dummy app for pow to work
  * Merge branch 'feature/bootstrap' of github.com:katalyst/koi into feature/bootstrap
  * Merge branch 'develop' of github.com:katalyst/koi into feature/bootstrap
  * more cleaning up of asset manager and pagination now in
  * asset manager styling - in progress
  * Styling modalz.
  * Renamed sp to space.
  * Styletastic.
  * Merged develop.
  * Shifting some units.
  * Style refactorismo.
  * Style-a-rooney.
  * Added inline simple_form wrapper.
  * various form and list tweaks for admin
  * Moved Bowerbird into a gem.
  * Restructured the Bowerbird / Bootstrap stylesheets.
  * form styling, buttons and various other tweaks
  * top menu bar
  * Upgraded to simple form 2 Added SASS Bootstrap Changed all form to use bootstrap styles
