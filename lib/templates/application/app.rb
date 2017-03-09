#
# When working with this file, it might help to enable binding.pry
#
# require 'pry'
# binding.pry
#
# override Thor's source_paths method to include the rails_root directory in lib/templates/application/rails_root
# For consistency, any files we want to copy into the app should be placed inside rails_root,
# following the rails folder structure.
#

def source_paths
  Array(super) + [File.join(File.expand_path(File.dirname(__FILE__)),'rails_root')]
end

# Method to lookup the version of koi
def koi_version
  version_file_path = self.rails_template[/.*(?=templates)/]
  version_file_path += 'koi/version.rb'
  version_data = open(version_file_path) {|f| f.read }

  version = version_data.split("\n")[1].split('=').last.strip.gsub(/\"/, '')
end

# Add .ruby-version for RVM/RBENV.
create_file '.ruby-version', <<-END
2.2.2
END

# Add .ruby-gemset for RVM
create_file '.ruby-gemset', <<-END
koiv2-gem
END

# Add .rbenv-gemsets for RBENV
create_file '.rbenv-gemsets', <<-END
koiv2-gem
END

# Add .envrc for direnv to autoload ./bin in PATH
create_file '.envrc', <<-END
PATH_add ./bin
END

# jQuery UI
gem "jquery-ui-rails"

# Airbrake
gem "airbrake"                  , '4.3'

# Nested fields
gem 'awesome_nested_fields'     , github: 'katalyst/awesome_nested_fields'

# Koi Config
gem 'koi_config'                , github: 'katalyst/koi_config'

# Koi CMS
gem 'koi'                       , github: 'katalyst/koi',
                                  tag: "v#{koi_version}"

# Compass
gem 'compass'                   , "~> 1.0.0"

gem 'compass-rails'             , "~> 2.0.2"

# i18n ActiveRecord backend
gem 'i18n-active_record',   github: 'svenfuchs/i18n-active_record',
                            require: 'i18n/active_record',
                            ref: 'b26c2e62e32df2f3b9ae42083647725b7ecfdff0'

gem 'active_model_serializers'

gem 'unicorn'

gem 'newrelic_rpm'

gem 'ey_config'

gem 'sidekiq'

gem_group :development do
  gem 'karo'
  gem 'pry-rails'
  gem 'web-console', '~> 2.0'
  gem 'engineyard'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'ornament', github: 'katalyst/ornament'
end

# Setup mailer host
application(nil, :env => 'development') do
  "config.action_mailer.asset_host = \"http://localhost:3000\""
end

# Create Version File
create_file 'VERSION', <<-END
1.0.0
END

# Setup database yml
run 'rm config/database.yml'
create_file 'config/database.yml', <<-END
default: &default
  adapter: postgresql
  encoding: unicode
  pool: 5
  username: deploy
  host: localhost

development:
  <<: *default
  database: #{@app_name}_development

test:
  <<: *default
  database: #{@app_name}_test

production:
  <<: *default
  database: #{@app_name}_development

END

# Setup seed
run 'rm db/seeds.rb'
create_file 'db/seeds.rb', <<-END
Koi::Engine.load_seed
END

# Setup seed
run 'rm db/seeds.rb'
create_file 'db/seeds.rb', <<-END
Koi::Engine.load_seed
END

# Crud Controller that can be extended per project
create_file 'app/controllers/common_controller_actions.rb', <<-END
module CommonControllerActions

  extend ActiveSupport::Concern

  included do
    protect_from_forgery
    layout :layout_by_resource
    helper :all
    helper Koi::NavigationHelper
    helper_method :seo
    before_filter :sign_in_as_admin! if Rails.env.development?
  end

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

  def sign_in_as_admin!
    sign_in(:admin, Admin.first) unless Admin.all.empty?
  end

  def seo(name)
    begin
      is_a_resource? ? resource.setting(name, nil, role: 'Admin') : resource_class.setting(name, nil, role: 'Admin')
    rescue
    end
  end

  # Is the current page an Inherited Resources resource?
  def is_a_resource?
    begin
      !!resource
    rescue
      false
    end
  end

end
END

# Including common controller methods into application controller
run 'rm app/controllers/application_controller.rb'
create_file 'app/controllers/application_controller.rb', <<-END
class ApplicationController < ActionController::Base

  include CommonControllerActions

end
END

# Crud Controller that can be extended per project
create_file 'app/controllers/crud_controller.rb', <<-END
class CrudController < Koi::CrudController

  include CommonControllerActions

end
END

# import Pages controller
copy_file 'app/controllers/pages_controller.rb'

run 'bundle install'

# Generate .karo.yml file
create_file '.karo.yml', <<-END
production:
  host: koiv2productionv2.engineyard.katalyst.com.au
  user: deploy
  path: /data/#{@app_name.gsub("-", "_")}
  commands:
    client:
      deploy: ey deploy -e koiv2productionv2
staging:
  host: koiv2staging.engineyard.katalyst.com.au
  user: deploy
  path: /data/#{@app_name.gsub("-", "_")}
  commands:
    client:
      deploy: ey deploy -e koiv2staging
END

# Install Migrations
rake 'koi:install:migrations'

# Convert url's like this /pages/about-us into /about-us
route 'get "/:id"  => "pages#show", as: :page'

# Koi Engine route
route 'mount Koi::Engine => "/admin", as: "koi_engine"'

# Compile Assets on Server
gsub_file 'config/environments/production.rb', 'config.assets.compile = false', 'config.assets.compile = true'

rake 'db:drop'
rake 'db:create'

# HACK: To by pass devise checking for secret key without initialization
create_file 'config/initializers/devise.rb', <<-END
Devise.setup do |config|
  config.secret_key = 'Temporarily created to fix the devise install error'
end
END

# Generate Devise Config
generate('devise:install -f')

# Change scoped views
gsub_file 'config/initializers/devise.rb', '# config.secret_key', 'config.secret_key'
gsub_file 'config/initializers/devise.rb', 'please-change-me-at-config-initializers-devise@example.com', 'no-reply@katalyst.com.au'
gsub_file 'config/initializers/devise.rb', '# config.scoped_views = false', 'config.scoped_views = true'

rake 'db:migrate'

route "root to: 'pages#index'"

route 'resources :pages, only: [:index, :show], as: :koi_pages'
route 'resources :assets, only: [:show]'
route 'resources :images, only: [:show]'
route 'resources :documents, only: [:show]'

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

# Setup Airbrake
create_file 'config/initializers/airbrake.rb', <<-END
Airbrake.configure do |config|
  config.api_key    = Figaro.env.airbrake_api_key
  config.host       = Figaro.env.airbrake_host
  config.port       = Figaro.env.airbrake_port.to_i
  config.secure     = Figaro.env.airbrake_secure == 'true'
  config.project_id = Figaro.env.airbrake_api_key
end

class Airbrake::Sender
  def json_api_enabled?
    true
  end
end
END

# Setup sidekiq passenger hack
create_file 'config/initializers/sidekiq.rb', <<-END
default_config = { namespace: "#{@app_name}" }

Sidekiq.configure_server do |config|
  config.redis = default_config
  # if scheduled jobs execute later than than expected uncomment this next line
  # this should reduce the polling to 5 seconds
  # config.poll_interval = 5
end

Sidekiq.configure_client do |config|
  config.redis = default_config
end
END

# Setup sidekiq deploy hook
create_file 'deploy/after_restart.rb', <<-END
on_app_servers do
  sudo "monit restart all -g #{@app_name.gsub('-', '_')}_sidekiq"
end
END

# Setup koi initializer to define admin menu and other koi related settings
create_file 'config/initializers/koi.rb', <<-END
Koi::Menu.items = {
  "Modules" => {

  },
  "Advanced" => {
    "Admins"       => "/admin/site_users",
    "URL History"  => "/admin/friendly_id_slugs",
    "URL Rewriter" => "/admin/url_rewrites"
  }
}

Koi::Settings.collection = {
  title:            { label: "Title",            group: "SEO", field_type: 'string', role: 'Admin' },
  meta_description: { label: "Meta Description", group: "SEO", field_type: 'text', role: 'Admin' },
  meta_keywords:    { label: "Meta Keywords",    group: "SEO", field_type: 'text', role: 'Admin' }
}

Koi::Settings.resource = {
  title:            { label: "Title",            group: "SEO", field_type: 'string', role: 'Admin' },
  meta_description: { label: "Meta Description", group: "SEO", field_type: 'text', role: 'Admin' },
  meta_keywords:    { label: "Meta Keywords",    group: "SEO", field_type: 'text', role: 'Admin' }
}
END

# Setup Fiagro application.yml
application_yml = <<-END
MANDRILL_USERNAME:  ''
MANDRILL_PASSWORD:  ''
MAILTRAP_USERNAME:  ''
MAILTRAP_PASSWORD:  ''
SECRET_KEY_BASE:    ''
AIRBRAKE_API_KEY:   ''
AIRBRAKE_HOST:      'errbit.katalyst.com.au'
AIRBRAKE_PORT:      '443'
AIRBRAKE_SECURE:    'true'
DEFAULT_TO_ADDRESS: 'admin@katalyst.com.au'
NO_REPLY_ADDRESS:   'no-reply@katalyst.com.au'
END

create_file 'config/application.yml.example', application_yml
create_file 'config/application.yml', application_yml

# Setup fiagro deploy hook
create_file 'deploy/after_symlink.rb', <<-END
on_app_servers do
  run "ln -nfs \#{config.shared_path}/config/application.yml \#{config.current_path}/config/application.yml"
end
END

# Setup sendgrid initializer
create_file 'config/initializers/setup_smtp.rb', <<-END
mock_smtp_indicator = Rails.root + 'tmp/mock_smtp.txt'

if mock_smtp_indicator.exist?
  ActionMailer::Base.smtp_settings = {
    address: 'localhost',
    port: 1025,
    domain: 'katalyst.com.au'
  }
elsif Rails.env.production?
  ActionMailer::Base.smtp_settings = {
    address: 'smtp.mandrillapp.com',
    port: '587',
    authentication: :plain,
    user_name: Figaro.env.mandrill_username,
    password: Figaro.env.mandrill_password
  }
else
  ActionMailer::Base.smtp_settings = {
    user_name: Figaro.env.mailtrap_username,
    password: Figaro.env.mailtrap_password,
    address: 'mailtrap.io',
    domain: 'mailtrap.io',
    port: '2525',
    authentication: :cram_md5,
    enable_starttls_auto: true
  }
end
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

# Ignore application configuration
/config/application.yml

# NPM packages
/node_modules
END

generate('ornament -f') if yes?("Do you want to generate ornament?")

git :init
git add: '.'
git commit: "-m 'Initial Commit'"

run 'ey init'
git add: '.'
git commit: "-m 'Generated EngineYard Config'"

rake 'db:seed'
