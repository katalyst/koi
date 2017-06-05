module Koi
  module Sitemap
    mattr_accessor :toggles
    @@toggles = true

    mattr_accessor :root_items
    @@root_items = [
      { 
        "title" => "Home", 
        "url"   => "/", 
        "key"   => "home" 
      }
    ]
  end
end
