# frozen_string_literal: true

Time::DATE_FORMATS[:pretty] = ->(time) { time.strftime("%a, %b %e at %l:%M") + time.strftime("%p").downcase }
Date::DATE_FORMATS[:default] = "%d %b %Y"
Time::DATE_FORMATS[:default] = "%a, %b %e at %l:%M %p"
