module Koi
  class Router
    def initialize
      @resources = []
    end

    def register_resource(resource, actions)
      @resources << [resource.name.downcase.pluralize.to_sym, actions]
    end

    def draw(router)
      router.namespace :admin do
        @resources.each do |resource, actions|
          router.resources resource, only: actions
        end
      end
    end
  end
end
