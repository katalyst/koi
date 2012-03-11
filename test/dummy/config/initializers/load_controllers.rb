Dir.glob("#{Rails.root}/app/controllers/**/*.rb").each { |c| require c }
