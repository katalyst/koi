# frozen_string_literal: true

module Koi
  class TableComponent < Katalyst::TableComponent
    include Tables::Cells

    def output_preamble
      '<div class="table-container">'.html_safe + super
    end

    def output_postamble
      super + "</div>".html_safe
    end
  end
end
