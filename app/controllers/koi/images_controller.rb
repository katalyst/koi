module Koi
  class ImagesController < AssetsController
    defaults :route_prefix => '', :resource_class => Image
  end
end