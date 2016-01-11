# MenuScene

phina.define 'MenuScene',
  superClass: 'phina.display.CanvasScene'

  _static:
    defaults:
      cols:     1
      padding:  8
      menuOptions: {}
      labelOptions: {}

      fontSize: 32
      fontWeight: ''
      fontFamily: "'HiraKakuProN-W3'"

      menuFill: 'blue'

  init: (options={}) ->
    @superInit(options)
    {
      @cols
      @rows
      @padding
      @menus
      @fontFamily
      @fontSize
      @fontWeight
    } = {}.$safe(options).$safe MenuScene.defaults

    @index = 0

    @rows       = @_calcRows()
    @itemWidth  = @_calcItemWidth()
    @itemHeight = @_calcItemHeight()

    @width  = @itemWidth  * @cols + (@cols + 1) * @padding
    @height = @itemHeight * @rows + (@rows + 1) * @padding
    
    @menu = phina.display.RectangleShape().addChildTo @
    @menu.x = @gridX.center()
    @menu.y = @gridY.center()
    @menu.width  = @width
    @menu.height = @height
    @menu.gridX = phina.util.Grid(@width  - @padding, @cols, true)
    @menu.gridY = phina.util.Grid(@height - @padding, @rows, true, - @menu.height / 2 + @itemHeight / 2 + @padding)

    @cursor = phina.display.RectangleShape
      width:  @itemWidth
      height: @itemHeight
      stroke:       'white'
      strokeWidth:  3
      visible:      true
      cornerRadius: 5
      fill:         'rgba(255,255,255,0.2)'
      backgroundColor: 'transparent'
    @cursor.addChildTo @menu
    @btns = []
    for m,i in @menus
      btn = phina.ui.Button
        text:   m.text
        width:  @itemWidth
        height: @itemHeight
        stroke: false
        fill:   false
      .addChildTo @menu
      .on 'push', @_selectMenu.bind @
      btn.index = i
      btn.x = @menu.gridX.span i % @cols
      btn.y = @menu.gridY.span (i / @cols).floor()
      @btns.push btn

    @cursor.x = @btns[@index].x
    @cursor.y = @btns[@index].y

    #@setupKeyboradHander()
    #@setupCursorHandler (e) ->
    #  console.log e.type
    #  return
    @on 'keydown', (e) ->
      switch e.keyCode
        when phina.input.Keyboard.KEY_CODE['up']
          if @index > 0
            @index -= 1
          else
            @index = @menus.length - 1
        when phina.input.Keyboard.KEY_CODE['down']
          if @index < @menus.length - 1
            @index += 1
          else
            @index = 0
        when phina.input.Keyboard.KEY_CODE['left']
          if @index > 0
            @index -= 1
          else
            @index = @menus.length - 1
        when phina.input.Keyboard.KEY_CODE['right']
          if @index < @menus.length - 1
            @index += 1
          else
            @index = 0
        when phina.input.Keyboard.KEY_CODE['enter']
          @btns[@index].flare('push')
          return
      @cursor.x = @btns[@index].x
      @cursor.y = @btns[@index].y
      return
    return

  _selectMenu: (e) ->
    menu = @menus[e.target.index]
    if menu?
      @app.popScene()
      menu.fn()
    return

  _measureText: (text,options) ->
    canvas = phina.graphics.Canvas.dummyCanvas
    context = canvas.getContext('2d')
    context.font = "{fontWeight} {fontSize}px {fontFamily}".format(options)
    context.measureText(text + '').width

  _calcRows: ->
    @rows ? (@menus.length / @cols).ceil()

  _calcItemWidth: ->
    width = 0
    for m,i in @menus
      w = @_measureText(m.text,@)
      width = w if width < w
    width + 4

  _calcItemHeight: ->
    @fontSize

