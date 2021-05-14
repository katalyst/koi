module Koi::StyleguideHelper

  # Render source code
  def render_source(code)
    h(code&.to_param)
  end

end
