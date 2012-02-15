module Koi
  class DocumentsController < AssetsController
    defaults :route_prefix => '', :resource_class => Document
  end
end
