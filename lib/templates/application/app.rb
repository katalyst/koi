# Overwrite for default rails
gem 'jquery-rails'

# Koi Config
gem 'koi_config', :git => 'git@github.com:katalyst/koi_config.git'

# Inherited Resources
gem 'inherited_resources'       , :git => 'git@github.com:marcelloma/inherited_resources.git'

# Nested fields
gem 'awesome_nested_fields'     , :git => "git@github.com:katalyst/awesome_nested_fields.git"

# Koi CMS
gem 'koi'                       , :path => "/Users/rahult/Development/katalyst/rails/gems/koi"

# Ruby debugger
gem 'ruby-debug19'              , :require => 'ruby-debug'

# Gems used only for assets and not required
# in production environments by default.
gem_group :assets do
  gem 'sass-rails'              , '~> 3.2.3'
  gem 'coffee-rails'            , '~> 3.2.1'
  gem 'uglifier'                , '>= 1.0.3'
end

# Setup rvm
file ".rvmrc", <<-END
rvm use ruby-1.9.2-p136@koi-gem --create
END

run 'bundle install'

application(nil, :env => "development") do
  "config.action_mailer.default_url_options = { :host => 'localhost:3000' }"
end

# Setup database yml
run 'rm config/database.yml'
file "config/database.yml", <<-END
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
file "db/seeds.rb", <<-END
Koi::Engine.load_seed
END

git :init
git :add => "."
git :commit => "-m Initial Commit!"

rake("db:create")

generate("koi:controller", "super_hero title:string description:text")
generate("koi:admin_controller", "super_hero title:string description:text --skip-model")

rake("db:migrate")
rake("db:seed")
