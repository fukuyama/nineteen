# MenuScene

phina.define 'MenuScene',
  superClass: phina.display.CanvasScene

  _measureText: (text,obj) ->
    canvas = phina.graphics.Canvas.dummyCanvas
    context = canvas.getContext('2d')
    context.font = "{fontWeight} {fontSize}px {fontFamily}".format(obj)
    context.measureText(text + '').width

  init: (options={}) ->
    @superInit(options)

    {
      @padding
      @fontSize
      @fontFamily
      @cols
      @rows
      @menus
    } = options.$safe
      padding:  8
      fontSize: 32
      fontFamily: "'HiraKakuProN-W3'"
      cols:     1
      menus: [
        {text: 'menu1'}
        {text: 'menu2test'}
      ]

    @rows   = (@menus.length / @cols).ceil() unless @rows?

    @menuWidth  = 0
    @menuHeight = @fontSize

    for m,i in @menus
      w = @_measureText(m.text,@)
      @menuWidth = w if @menuWidth < w

    @width  = @menuWidth  * @cols + (@cols - 1) * @padding + @padding * 2
    @height = @menuHeight * @rows + (@rows - 1) * @padding + @padding * 2

    @menu = phina.display.RectangleShape(width:@width,height:@height).addChildTo @
    @menu.x = @gridX.center()
    @menu.y = @gridY.center()
    @menu.gridX = phina.util.Grid(@menu.width,  @cols)
    @menu.gridY = phina.util.Grid(@menu.height, @rows)

    for m,i in @menus
      label = phina.display.Label
        text:     m.text
        fill:     'white'
        stroke:   false
        originX:  0.0
        originY:  1.0
        fontSize: @fontSize
        fontFamily: @fontFamily
        #backgroundColor: '#aaa'
        lineHeight: 1.0
      .addChildTo @menu
      label.x = @menu.gridX.span(i % @cols)
      label.y = @menu.gridY.span((i / @cols).floor())
      # - @menuHeight / 2 - @padding

    return
