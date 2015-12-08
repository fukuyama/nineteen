# MenuScene

phina.define 'MenuScene',
  superClass: 'phina.display.CanvasScene'

  _static:
    defaults:
      init:
        cols:     1
        padding:  8
        menuOptions: {}
        labelOptions: {}
      menuOptions:
        fill: '#008'
      labelOptions:
        fontSize:   32
        fontFamily: "'HiraKakuProN-W3'"
        fill:       'white'
        stroke:     false
        backgroundColor: '#aaa'
        lineHeight: 1.2


  init: (options={}) ->
    @superInit(options)

    {
      @cols
      @rows
      @padding
      @menus
      menuOptions
      labelOptions
    } = {}.$safe(options).$safe MenuScene.defaults.init
    @menuOptions  = menuOptions.$safe MenuScene.defaults.menuOptions
    @labelOptions = labelOptions.$safe MenuScene.defaults.labelOptions

    @rows = (@menus.length / @cols).ceil() unless @rows?
    @menuWidth  = @_calcMenuWidth()
    @menuHeight = @_calcMenuHeight()

    @width  = @menuWidth  * @cols + (@cols + 1) * @padding
    @height = @menuHeight * @rows + (@rows + 1) * @padding
    
    @menu = phina.display.RectangleShape(@menuOptions).addChildTo @
    @menu.x = @gridX.center()
    @menu.y = @gridY.center()
    @menu.width  = @width
    @menu.height = @height
    @menu.gridX = phina.util.Grid(@width  - @padding, @cols, true)
    @menu.gridY = phina.util.Grid(@height - @padding, @rows, true, - @menu.height / 2 + @menuHeight / 2 + @padding)

    for m,i in @menus
      btn = phina.ui.Button
        width:  @menuWidth
        height: @menuHeight
        stroke: false
        fill:   false
        text:   m.text
      btn.x = @menu.gridX.span i % @cols
      btn.y = @menu.gridY.span (i / @cols).floor()
      btn.addChildTo @menu

    return

  _measureText: (text,options) ->
    canvas = phina.graphics.Canvas.dummyCanvas
    context = canvas.getContext('2d')
    context.font = "{fontWeight} {fontSize}px {fontFamily}".format(options)
    context.measureText(text + '').width

  _calcMenuWidth: ->
    width = 0
    for m,i in @menus
      w = @_measureText(m.text,@labelOptions)
      width = w if width < w
    width + 4

  _calcMenuHeight: ->
    @labelOptions.fontSize

