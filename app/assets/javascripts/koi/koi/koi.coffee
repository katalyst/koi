$ = jQuery

$.extend $,

  application: ( args..., f ) ->
    try f.apply @, args catch e then throw e if $.application.debug

$.extend $.fn,

  application: ( args... ) ->
    live = if typeof args[0] is 'boolean' then args.shift() else false
    [ f ] = args

    fStar = -> $( @ ).each ( i, e ) -> $.application.call( e, $(e), f )
    $ => if live then @liveQuery fStar else fStar.call @
    @

  components: ( args... ) ->
    live = if typeof args[0] is 'boolean' then args.shift() else false
    [ selector, f ] = args

    $components = @find( selector ).filter ( i, e ) => $( e ).isComponentOf( @ )
    $components.application live, f if f
    $components

  isComponentOf: ( object ) ->
    $( @ ).componentOf()[0] is $( object )[0]

  componentOf: ->
    $parent = @
    while ($parent = $parent.parent()).length
      return $parent if $parent.hasClass "application"
    $()

$.fn.component = $.fn.components
