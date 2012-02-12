# Default Super admin
Admin.create(first_name: "Admin", last_name: "Katalyst", email: "admin@katalyst.com.au",
             role: "Super", password: "1S*f91$l9", password_confirmation: "1S*f91$l9")

# RootNavItem.create!(title: "Home", url: "/", key: "home")
header = FolderNavItem.create!(title: "Header Navigation", parent: RootNavItem.root, key: "header_navigation")
footer = FolderNavItem.create!(title: "Footer Navigation", parent: RootNavItem.root, key: "footer_navigation")

# Few Header Pages
about_us_page   = Page.create!(title: "About Us").to_navigator!(parent_id: header.id)
contact_us_page = Page.create!(title: "Contact Us").to_navigator!(parent_id: header.id)
categories_module = ModuleNavItem.create!(title: "Categories", url: "/categories",
                                          admin_url: "/admin/categories", parent_id: header.id,
                                          content_block: "")

# Few Aliases
AliasNavItem.create!(title: "About Us", alias_id: about_us_page.id, parent: footer)
AliasNavItem.create!(title: "Contact Us", alias_id: contact_us_page.id, parent: footer)

# One Footer Pages
privacy_policy_page = Page.create!(title: "Privacy Policy").to_navigator!(parent_id: footer.id)
