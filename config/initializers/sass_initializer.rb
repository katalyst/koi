# Include assets/stylesheets/koi in sass load paths to enable custom koi sass
Rails.application.config.sass.load_paths += [Rails.root.join('app', 'assets', 'stylesheets', 'koi')]