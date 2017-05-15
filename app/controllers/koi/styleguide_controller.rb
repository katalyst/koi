module Koi
  class StyleguideController < ApplicationController
    helper "koi/styleguide"

    def page
      render params[:page]
    end
  end
end
