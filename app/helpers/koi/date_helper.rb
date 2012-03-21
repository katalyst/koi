module Koi::DateHelper

  def date_format(date, format)
    date.strftime format.gsub(/yyyy/,  "%Y")
                        .gsub(/yy/,    "%y")
                        .gsub(/Month/, "%B")
                        .gsub(/M/,     "%b")
                        .gsub(/mm/,    "%m")
                        .gsub(/m/,     "%-m")
                        .gsub(/Day/,   "%A")
                        .gsub(/D/,     "%a")
                        .gsub(/dd/,    "%d")
                        .gsub(/d/,     "%-d")
  end

  def date_Month_d_yyyy(date)
    date.strftime "%B %-d, %Y"
  end

  def date_d_Month_yyyy(date)
    date.strftime "%-d %B %Y"
  end

  def date_d_M_yy(date)
    date.strftime "%-d %b %y"
  end

end