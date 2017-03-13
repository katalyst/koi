require 'htmlentities'

module Koi::StyleguideHelper

  # Render source code
  def render_source(code)
    begin
      @html_encoder ||= HTMLEntities.new
      raw(@html_encoder.encode(code))
    rescue NameError
      raw("<div class='panel--padding'>Error rendering HTML, HTMLEntities gem is possibly missing</div>")
    end
  end

end