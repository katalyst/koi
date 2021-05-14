require_relative "middleware/url_redirect"

module Koi
  class Engine < ::Rails::Engine

    isolate_namespace Koi

    initializer "static assets" do |app|
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
      app.middleware.use Koi::UrlRedirect
      app.config.assets.precompile += %w(
        koi/modernizr.js
        selectivizr.js
        css3-mediaqueries.js
        application_bottom.js
        koi.js
        koi/nav_items.js
        koi/assets.js
        koi/application.css
        koi/application/glyphicons-halflings.png
        koi/application/glyphicons-halflings-white.png
        koi/application/icon-collapse-down.png
        koi/application/icon-collapse-up.png
        koi/application/icon-file-doc.png
        koi/application/icon-file-img.png
        koi/application/icon-file-pdf.png
        koi/application/icon-file-ppt.png
        koi/application/icon-file-unknown.png
        koi/application/icon-file-xls.png
        koi/application/icon-file-zip.png
        koi/application/icon-form-date-picker.png
        koi/application/icon-form-error.png
        koi/application/icon-index-sort.png
        koi/application/icon-index-sort-ascending.png
        koi/application/icon-index-sort-descending.png
        koi/application/icon-index-sortable.png
        koi/application/icon-menu-cursor.png
        koi/application/icon-overlay-add.png
        koi/application/icon-overlay-close.png
        koi/application/icon-sortable.png
        koi/application/jcrop.gif
        koi/application/loading.gif
        koi/application/logo-katalyst.png
        koi/application/logo-katalyst-devise.png
        koi/application/logo-katalyst-header.png
        koi/application/placeholder-image-none.png
        koi/application/select_arrow.png
        koi/application/sort-ascending.png
        koi/application/sort-descending.png
      )
    end

  end
end
