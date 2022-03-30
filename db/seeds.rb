# frozen_string_literal: true

require "securerandom"
require "thor"
thor = Thor::Shell::Basic.new

unless Admin.find_by(email: "admin@katalyst.com.au")
  password = SecureRandom.base58(16)

  thor.say("Your admin@katalyst.com.au password has been set to #{password}, please update your password manager",
           :green)

  # Default Super admin
  Admin.create(first_name: "Admin", last_name: "Katalyst", email: "admin@katalyst.com.au",
               role: "Super", password: password, password_confirmation: password)
end

# RootNavItem.create!(title: "Home", url: "/", key: "home")
header = FolderNavItem.create!({ title: "Header Navigation", parent: RootNavItem.root, key: "header_navigation" })
footer = FolderNavItem.create!({ title: "Footer Navigation", parent: RootNavItem.root, key: "footer_navigation" })

# Few Header Pages
home_page       = Page.create!({ title: "Home Page" }).to_navigator!(parent_id: header.id)
about_us_page   = Page.create!({ title: "About Us" }).to_navigator!(parent_id: header.id)
contact_us_page = Page.create!({ title: "Contact Us" }).to_navigator!(parent_id: home_page.id)

# Few Aliases
AliasNavItem.create!({ title: "About Us", alias_id: about_us_page.id, parent: footer })
AliasNavItem.create!({ title: "Contact Us", alias_id: contact_us_page.id, parent: footer })

# One Footer Pages
Page.create!({ title: "Privacy Policy" }).to_navigator!(parent_id: footer.id)

# Settings
Translation.create!({ prefix: "site", label: "Site Title", key: "site.title", value: "", field_type: "string",
                      role: "Admin" })
Translation.create!({ prefix: "site", label: "Site Meta Description", key: "site.meta_description", value: "",
                      field_type: "text", role: "Admin" })
Translation.create!({ prefix: "site", label: "Site Meta Keywords", key: "site.meta_keywords", value: "",
                      field_type: "text", role: "Admin" })
Translation.create!({ prefix: "site", label: "Google Analytics Profile ID", key: "site.google_analytics.profile_id",
                      value: "", field_type: "string", role: "Admin" })
Translation.create!({ prefix: "site", label: "Twitter Search Query", key: "site.twitter.widget_id", value: "",
                      field_type: "string", role: "Admin" })
