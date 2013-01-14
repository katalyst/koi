# Setup rvm
create_file '.rvmrc', <<-END
rvm use ruby-1.9.2-p290@koi-gem --create
END

# Setup pow
create_file '.powrc', <<-END
if [ -f "$rvm_path/scripts/rvm" ] && [ -f ".rvmrc" ]; then
  source "$rvm_path/scripts/rvm"
  source ".rvmrc"
fi
END

# Nested fields
gem 'awesome_nested_fields'     , :git => 'git://github.com/katalyst/awesome_nested_fields.git'

# Koi Config
gem 'koi_config'                , :git => 'git://github.com/katalyst/koi_config.git'

# Koi CMS
gem 'koi'                       , :git => 'git://github.com/katalyst/koi.git',
                                  :branch => 'v1.0.0.beta'

# Bowerbird
gem 'bowerbird_v2'              , :git => 'git@github.com:katalyst/bowerbird_v2.git'

# i18n ActiveRecord backend
gem 'i18n-active_record'        , :git => 'git://github.com/svenfuchs/i18n-active_record.git',
                                  :branch => 'rails-3.2',
                                  :require => 'i18n/active_record'

gem 'unicorn'

gem_group :development do
  # Ruby debugger
  gem 'ruby-debug19'            , :require => 'ruby-debug'
  # Engineyard
  gem 'engineyard'
  # Console
  gem 'powder'
end

application(nil, :env => 'development') do
  "config.action_mailer.default_url_options = { :host => 'localhost:3000' }"
end

# Create Version File
create_file 'VERSION', <<-END
1.0.0
END

# Setup database yml
run 'rm config/database.yml'
create_file 'config/database.yml', <<-END
development:
  adapter: mysql2
  encoding: utf8
  reconnect: false
  host: localhost
  database: #{@app_name}_development
  pool: 5
  username: root
  password: katalyst

test:
  adapter: mysql2
  encoding: utf8
  reconnect: false
  host: localhost
  database: #{@app_name}_test
  pool: 5
  username: root
  password: katalyst
END

# Setup seed
run 'rm db/seeds.rb'
create_file 'db/seeds.rb', <<-END
Koi::Engine.load_seed
END

# Setup seed
run 'rm app/controllers/application_controller.rb'
create_file 'app/controllers/application_controller.rb', <<-END
class ApplicationController < ActionController::Base
  protect_from_forgery
  layout :layout_by_resource
  helper Koi::NavigationHelper

protected

  # FIXME: Hack to set layout for admin devise resources
  def layout_by_resource
    if devise_controller? && resource_name == :admin
      "koi/devise"
    else
      "application"
    end
  end

  # FIXME: Hack to redirect back to admin after admin login
  def after_sign_in_path_for(resource_or_scope)
    resource_or_scope.is_a?(Admin) ? koi_engine.root_path : super
  end

  # FIXME: Hack to redirect back to admin after admin logout
  def after_sign_out_path_for(resource_or_scope)
    resource_or_scope == :admin ? koi_engine.root_path : super
  end
end
END

run 'bundle install'


# Install Migrations
rake 'koi:install:migrations'

route "mount Koi::Engine => '/admin', as: 'koi_engine'"

run 'rm public/index.html'

# Disable Whitelist Attribute
gsub_file 'config/application.rb', 'config.active_record.whitelist_attributes = true', 'config.active_record.whitelist_attributes = false'

# Compile Assets on Server
# gsub_file 'config/environments/staging.rb', 'config.assets.compile = false', 'config.assets.compile = true'
# gsub_file 'config/environments/production.rb', 'config.assets.compile = false', 'config.assets.compile = true'

rake 'db:drop'
rake 'db:create'
rake 'db:migrate'

# Generate Devise Config
generate('devise:install')

# Change scoped views
gsub_file 'config/initializers/devise.rb', '# config.scoped_views = false', 'config.scoped_views = true'

route "root to: 'pages#index'"

route 'resources :pages'
route 'resources :assets'
route 'resources :images'
route 'resources :documents'

create_file 'config/navigation.rb', <<-END
# -*- coding: utf-8 -*-
# Configures your navigation
SimpleNavigation.register_renderer :sf_menu => SfMenuRenderer
SimpleNavigation.register_renderer :active_items => ActiveItemsRenderer
SimpleNavigation::Configuration.run do |navigation|
end
END

create_file 'app/renderers/sf_menu_renderer.rb', <<-END
class SfMenuRenderer < SimpleNavigation::Renderer::List
  def render(item_container)
    item_container.dom_class = options.delete(:dom_class) if options.has_key?(:dom_class)
    item_container.dom_id = options.delete(:dom_id) if options.has_key?(:dom_id)
    item_container.items.each { |i| p i.html_options = { link: options[:link] } } if options.has_key?(:link)
    super
  end
end
END

create_file 'app/renderers/active_items_renderer.rb', <<-END
class ActiveItemsRenderer < SimpleNavigation::Renderer::Breadcrumbs
  def render(item_container)
    collect(item_container)
  end

  protected

  def collect(item_container)
    item_container.items.inject([]) do |list, item|
      if item.selected?
        list << NavItem.find_by_id(item.key.gsub("key_", "")).setting_prefix if item.selected?
        if include_sub_navigation?(item)
          list.concat collect(item.sub_navigation)
        end
      end
      list
    end
  end
end
END

# Setup Date Time formats
create_file 'config/initializers/datetime_formats.rb', <<-END
Time::DATE_FORMATS[:pretty] = lambda { |time| time.strftime("%a, %b %e at %l:%M") + time.strftime("%p").downcase }
Date::DATE_FORMATS[:default] = "%d %b %Y"
Time::DATE_FORMATS[:default] = "%a, %b %e at %l:%M %p"
Time::DATE_FORMATS[:short] = "%d.%m.%Y"
END

# Setup sidekiq passenger hack
create_file 'config/initializers/sidekiq.rb', <<-END
if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    Sidekiq.configure_client do |config|
      config.redis = { :size => 1 }
    end if forked
  end
end
END

create_file 'config/Initializers/koi.rb', <<-END
# FIXME: Explicity require all main app controllers
Dir.glob("app/controllers/admin/**/*.rb").each { |c| require Rails.root + c }

Koi::Menu.items = {
  'Admins' => '/admin/site_users'
}
END

# Setup up Git
run 'rm .gitignore'
file '.gitignore', <<-END
# Ignore bundler config
/.bundle

# Ignore the default SQLite database.
/db/*.sqlite3

# Ignore all logfiles and tempfiles.
/log/*.log
/tmp

# Ignore database yaml file
/config/database.yml

# Mac DS Store
.DS_Store

# System
public/system/**/*

# Ignore SASS cache files
.sass-cache/

# Ignore compiled assets
/public/assets
END

git :init
git :add => '.'
git :commit => "-m 'Initial Commit'"

rake 'db:seed'
