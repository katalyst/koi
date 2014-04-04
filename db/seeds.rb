require 'securerandom'
require 'thor'
thor = Thor::Shell::Basic.new

password = SecureRandom.hex(8)

if thor.yes?("Do you want me to set your password to #{password} ?", :yellow)
  thor.say("Your admin@katalyst.com.au password has been set, please update your wiki", :green)
else
  password = "katalyst"
  thor.say("Your admin@katalyst.com.au password has been set to `katalyst`, please update your wiki", :red)
end

# Default Super admin
Admin.create(first_name: "Admin", last_name: "Katalyst", email: "admin@katalyst.com.au",
             role: "Super", password: password, password_confirmation: password)

# RootNavItem.create!(title: "Home", url: "/", key: "home")
header = FolderNavItem.create!(title: "Header Navigation", parent: RootNavItem.root, key: "header_navigation")
footer = FolderNavItem.create!(title: "Footer Navigation", parent: RootNavItem.root, key: "footer_navigation")

# Few Header Pages
home_page        = Page.create!(title: "Home Page").to_navigator!(parent_id: header.id)
about_us_page    = Page.create!(title: "About Us").to_navigator!(parent_id: header.id)
contact_us_page  = Page.create!(title: "Contact Us").to_navigator!(parent_id: home_page.id)

# Few Aliases
AliasNavItem.create!(title: "About Us", alias_id: about_us_page.id, parent: footer)
AliasNavItem.create!(title: "Contact Us", alias_id: contact_us_page.id, parent: footer)

# One Footer Pages
privacy_policy_page = Page.create!(title: "Privacy Policy").to_navigator!(parent_id: footer.id)

# Settings
Translation.create!(label: "Site Title", key: "site.title", value: "Site Title", field_type: "string", role: "Admin")
Translation.create!(label: "Site Meta Description", key: "site.meta_description", value: "Meta Description", field_type: "text", role: "Admin")
Translation.create!(label: "Site Meta Keywords", key: "site.meta_keywords", value: "Meta Keywords", field_type: "text", role: "Admin")
Translation.create!(label: "Google Analytics", key: "site.google_analytics_embed", value: "<script></script>", field_type: "text", role: "Admin")
Translation.create!(label: "Google Analytics Username", key: "site.google_analytics.username", value: "admin@katalyst.com.au", field_type: "string", role: "Admin")
Translation.create!(label: "Google Analytics Password", key: "site.google_analytics.password", value: "yAw7c9rV", field_type: "string", role: "Admin")
Translation.create!(label: "Google Analytics Profile ID", key: "site.google_analytics.profile_id", value: "UA-2161859-1", field_type: "string", role: "Admin")
Translation.create!(label: "Show Google Analytics", key: "site.show.dashboard.analytics", value: "true", field_type: "boolean", role: "Super")
Translation.create!(label: "Twitter Search Query", key: "site.twitter.widget_id", value: "389900838295965696", field_type: "string", role: "Admin")
