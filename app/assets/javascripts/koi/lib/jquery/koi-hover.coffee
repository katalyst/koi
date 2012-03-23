$ = jQuery

$.fn.koiHover = ( args... ) ->
  delay = if typeof args[0] is 'number' then args.shift() else 0
  over = args.shift()
  leave = args.shift() or over

  @each =>
    nowRunning = false
    nowHovering = false

    @mouseover (e) ->
      nowHovering = true
      $.delay delay, ->
        if nowHovering
          nowRunning = true
          over.call @, e

    @mouseleave (e) ->
      nowHovering = false
      if nowRunning
        nowRunning = false
        leave.call @, e
