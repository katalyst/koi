module Koi
  module Settings
    class << self
      # Settings for all collections
      attr_accessor :collection

      # Settings for all resources
      attr_accessor :resource

      # Skip settings on create for all these resources
      attr_accessor :skip_on_create
    end

    @collection = {}
    @resource = {}
    @skip_on_create = []
  end
end
