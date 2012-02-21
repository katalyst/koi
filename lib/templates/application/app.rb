# Setup rvm
create_file '.rvmrc', <<-END
rvm use ruby-1.9.2-p290@koi-gem --create
END

# Nested fields
gem 'awesome_nested_fields'     , :git => 'git://github.com/katalyst/awesome_nested_fields.git'

# Koi Config
gem 'koi_config'                , :git => 'git://github.com/katalyst/koi_config.git'

# Koi CMS
gem 'koi'                       , :git => 'git://github.com/katalyst/koi.git'

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

# Generate Devise Config
generate('devise:install')

# Install Migrations
rake 'koi:install:migrations'

route "mount Koi::Engine => '/admin', as: 'koi_engine'"

run 'rm public/index.html'

rake 'db:drop'
rake 'db:create'

route "root to: 'pages#index'"

route 'resources :pages'

create_file 'config/navigation.rb', <<-END
# -*- coding: utf-8 -*-
# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
end
END

# Setup Initializer Example
create_file 'config/Initializers/koi.rb', <<-END
Koi::Menu.items = {
  'Pages' => '/admin/pages',
  'Admins' => '/admin/site_users'
}
END

rake 'db:migrate'
rake 'db:seed'

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
