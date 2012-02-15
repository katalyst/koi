module Koi::DateHelper

  def date_d_Month_yyyy(date)
    date.strftime "%-d %B %Y"
  end

  def date_d_M_yy(date)
    date.strftime "%-d %b %y"
  end

end