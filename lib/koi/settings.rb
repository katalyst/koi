module Koi
  module Settings
    # Settings for all collections
    mattr_accessor :collection
    @@collection = {}

    # Settings for all resources
    mattr_accessor :resource
    @@resource = {}

    # Skip settings on create for all these resources
    mattr_accessor :skip_on_create
    @@skip_on_create = []

    # Page cotnent settings
    mattr_accessor :page_content_settings
    @@page_content_settings = {}
  end
end
