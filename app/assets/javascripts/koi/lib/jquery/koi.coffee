#= require ./livequery

$ = jQuery

isGlobalConstructor = (X) ->
  X in [ Date, Number, String, RegExp, Function, Array, Object ]

isGlobal = (x) ->
  isGlobalConstructor x.constructor

$.extend $,

  application: ( args..., f ) ->
    try f.apply @, args catch e then throw e if $.application.debug

  delay: ( t, f ) ->
    setTimeout f, t

  poll: ( args... ) ->
    f = args.pop()
    t = f()
    t = args.shift() unless typeof t is 'number'
    $.delay t, -> $.poll args...

  log: if console?
    (x) -> console.log arguments...; x
  else
    (x) -> alert x; x

$.extend $.fn,

  or: (x) ->
    return @ if @length
    $ if typeof x is 'function' then x() else x

  maximum: (k) ->
    Math.max @map( -> $(@)[k]() ).toArray()...

  maximise: (k) ->
    @css( k, @maximum(k) )

  application: ( args... ) ->
    live = if typeof args[0] is 'boolean' then args.shift() else false
    [ f ] = args

    fStar = -> $( @ ).each ( i, e ) -> $.application.call( e, $(e), f )
    $ => @livequery fStar
    # $ => if live then @livequery fStar else fStar.call @
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

  dataCamel: ->
    camel = {}
    for i, e of @data()
      j = i.replace /[-_][a-zA-Z]/g, (w) -> w[1].toUpperCase()
      camel[ j ] = e
    camel

  options: ( opt = {}, defaults ) ->
    data = @dataCamel()
    for i, e of defaults
      opt[ i ] = if ( d = data[ i ] )?
        if isGlobalConstructor e
          new e d
        else
          new e.constructor d
      else
        e unless isGlobalConstructor e
    opt

  resolve: ( it ) ->
    if typeof it is 'function'
      it.call @[0], @
    else
      $ it

  cssGet: (hash) ->
    result = {}
    result[ i ] = @css( i ) for i of hash
    result

  cssReset: (hash) ->
    @css( i, "" ) for i of hash
    @

$.fn.component = $.fn.components