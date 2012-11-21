module Koi
  class DocumentsController < Koi::AssetsController
    defaults :route_prefix => '', :resource_class => Document
  end
end
