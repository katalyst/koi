# Default Super admin
Admin.create(first_name: "Admin", last_name: "Katalyst", email: "admin@katalyst.com.au",
             role: "Super", password: "katalyst", password_confirmation: "katalyst")

Admin.create(first_name: "Rahul", last_name: "Trikha", email: "rahul@katalyst.com.au",
             role: "Admin", password: "katalyst", password_confirmation: "katalyst")

Admin.create(first_name: "Jason", last_name: "Sidoryn", email: "jason@katalyst.com.au",
             role: "Admin", password: "katalyst", password_confirmation: "katalyst")

# RootNavItem.create!(title: "Home", url: "/", key: "home")
header = FolderNavItem.create!(title: "Header Navigation", parent: RootNavItem.root, key: "header_navigation")
footer = FolderNavItem.create!(title: "Footer Navigation", parent: RootNavItem.root, key: "footer_navigation")

# Few Header Pages
about_us_page   = Page.create!(title: "About Us").to_navigator!(parent_id: header.id)
contact_us_page = Page.create!(title: "Contact Us").to_navigator!(parent_id: header.id)

# Few Aliases
AliasNavItem.create!(title: "About Us", alias_id: about_us_page.id, parent: footer)
AliasNavItem.create!(title: "Contact Us", alias_id: contact_us_page.id, parent: footer)

# One Footer Pages
privacy_policy_page = Page.create!(title: "Privacy Policy").to_navigator!(parent_id: footer.id)

# Settings
Translation.create!(label: "Site Fonts", key: "site.fonts", value: "<script></script>", field_type: "text", role: "Super")
Translation.create!(label: "Site Title", key: "site.title", value: "Site Title", field_type: "string", role: "Admin")
Translation.create!(label: "Site Meta Description", key: "site.meta_description", value: "Meta Description", field_type: "text", role: "Admin")
Translation.create!(label: "Site Meta Keywords", key: "site.meta_keywords", value: "Meta Keywords", field_type: "text", role: "Admin")
Translation.create!(label: "Google Analytics", key: "site.google_analytics", value: "<script></script>", field_type: "text", role: "Admin")
Translation.create!(label: "Google Analytics Username", key: "site.google_analytics.username", value: "admin@katalyst.com.au", field_type: "string", role: "Admin")
Translation.create!(label: "Google Analytics Password", key: "site.google_analytics.password", value: "yAw7c9rV", field_type: "string", role: "Admin")
Translation.create!(label: "Google Analytics Profile ID", key: "site.google_analytics.profile_id", value: "UA-2161859-1", field_type: "string", role: "Admin")
Translation.create!(label: "Twitter Search Query", key: "site.twitter.query", value: "from:twitter OR #twitter", field_type: "string", role: "Admin")
