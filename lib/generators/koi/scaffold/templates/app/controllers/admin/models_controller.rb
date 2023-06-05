# frozen_string_literal: true

module Admin
  class ModelsController < ApplicationController

    before_action :set_SINGULAR_NAME, only: %i[show edit update destroy]

    def index
      @PLURAL_NAME = ::CLASS_NAME.strict_loading

      sort, @PLURAL_NAME = table_sort(@PLURAL_NAME)
      pagy, @PLURAL_NAME = pagy(@PLURAL_NAME)

      render locals: { PLURAL_NAME: @PLURAL_NAME, sort:, pagy: }
    end

    def show
      render locals: { SINGULAR_NAME: @SINGULAR_NAME }
    end

    def new
      render locals: { SINGULAR_NAME: ::CLASS_NAME.new }
    end

    def edit
      render locals: { SINGULAR_NAME: @SINGULAR_NAME }
    end

    def create
      @SINGULAR_NAME = ::CLASS_NAME.new(SINGULAR_NAME_params)

      if @SINGULAR_NAME.save
        redirect_to [:admin, @SINGULAR_NAME]
      else
        render :new, locals: { SINGULAR_NAME: @SINGULAR_NAME }, status: :unprocessable_entity
      end
    end

    def update
      if @SINGULAR_NAME.update(SINGULAR_NAME_params)
        redirect_to action: :show
      else
        render :edit, locals: { SINGULAR_NAME: @SINGULAR_NAME }, status: :unprocessable_entity
      end
    end

    def destroy
      @SINGULAR_NAME.destroy

      redirect_to action: :index
    end

    private

    def SINGULAR_NAME_params
      params.require(:SINGULAR_NAME).permit([])
    end

    def set_SINGULAR_NAME
      @SINGULAR_NAME = ::CLASS_NAME.find(params[:id])
    end
  end
end

