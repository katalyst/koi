module Koi
  module Navigation
    # Classes that should be available for navigation
    mattr_accessor :models
    @@models = []

    def each
      @@models.each { |m| yield m.safe_constantize }
    end
    module_function(:each)
  end
end
