# frozen_string_literal: true

module Koi
  class ImagesController < Koi::AssetsController
    defaults route_prefix: "", resource_class: Image
  end
end
