# Setup rvm
create_file '.rvmrc', <<-END
rvm use ruby-1.9.2-p290@koi-gem --create
END

# Koi Config
gem 'koi_config', :git => 'git@github.com:katalyst/koi_config.git'

# Nested fields
gem 'awesome_nested_fields'     , :git => 'git@github.com:katalyst/awesome_nested_fields.git'

# Koi CMS
gem 'koi'                       , :git => 'git://github.com/katalyst/koi.git'

gem_group :development do
  # Ruby debugger
  gem 'ruby-debug19'              , :require => 'ruby-debug'
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

run 'bundle install'

# Install Migrations
rake 'koi:install:migrations'

route "mount Koi::Engine => '/admin', as: 'koi_engine'"

run 'rm public/index.html'

rake 'db:drop'
rake 'db:create'

generate('koi:controller', 'super_hero title:string description:text')
generate('koi:admin_controller', 'super_hero title:string description:text --skip-model')

route "root to: 'super_heros#index'"

route 'resources :pages'

# Setup Initializer Example
create_file 'config/Initializers/koi.rb', <<-END
Koi::Menu.items = {
  'Super Heros' => '/admin/super_heros',
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
