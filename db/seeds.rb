# Default Super admin
Admin.create(first_name: "Admin", last_name: "Katalyst", email: "admin@katalyst.com.au",
             role: "Super", password: "katalyst", password_confirmation: "katalyst")

Admin.create(first_name: "Rahul", last_name: "Trikha", email: "rahul@katalyst.com.au",
             role: "Admin", password: "katalyst", password_confirmation: "katalyst")

# RootNavItem.create!(title: "Home", url: "/", key: "home")
header = FolderNavItem.create!(title: "Header Navigation", parent: RootNavItem.root, key: "header_navigation")
footer = FolderNavItem.create!(title: "Footer Navigation", parent: RootNavItem.root, key: "footer_navigation")

# Few Header Pages
about_us_page   = Page.create!(title: "About Us").to_navigator!(parent_id: header.id)
contact_us_page = Page.create!(title: "Contact Us").to_navigator!(parent_id: header.id)
super_heros_module = ModuleNavItem.create!(title: "Super Heros", url: "/super_heros",
                                          admin_url: "/admin/super_heros", parent_id: header.id,
                                          content_block: "")

# Few Aliases
AliasNavItem.create!(title: "About Us", alias_id: about_us_page.id, parent: footer)
AliasNavItem.create!(title: "Contact Us", alias_id: contact_us_page.id, parent: footer)

# One Footer Pages
privacy_policy_page = Page.create!(title: "Privacy Policy").to_navigator!(parent_id: footer.id)
