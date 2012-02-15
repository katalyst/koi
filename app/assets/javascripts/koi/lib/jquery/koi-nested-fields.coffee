$ = jQuery

$.fn.koiNestedFields = ->
  $this = $ @
  { min, max, count:n, class:className, attribute:attributeName  } = $this.data()

  selector          = ".class-#{className}.attribute-#{attributeName}"
  componentSelector = "#{selector}.nested-fields-"

  opt = {}
  ks  = 'container item empty add remove'.split ' '
  opt[ "#{k}Selector" ] = componentSelector + k for k in ks
  opt.itemTemplateSelector = componentSelector + "item-template"
  opt.emptyTemplateSelector = componentSelector + "empty-template"

  tidyInsert = ->
    $( opt.addSelector, $this ).hide() if n >= max
    $( opt.removeSelector, $this ).show() if n >  min

  tidyRemove = ->
    $( opt.addSelector, $this ).show() if n <  max
    $( opt.removeSelector, $this ).hide() if n <= min

  opt.beforeInsert = ( item, f ) ->
    return unless n < max
    n += 1
    tidyInsert()
    f()

  opt.beforeRemove = ( item, f ) ->
    return unless n > min
    n -= 1
    tidyRemove()
    f()

  $this.nestedFields opt
  $this.nestedFields 'insert' while n < min
  tidyInsert()
  tidyRemove()

