# MenuScene

phina.define 'MenuScene',
  superClass: phina.display.CanvasScene

  init: (options) ->
    @superInit(options)

    @bg = phina.display.RectangleShape(options.bg).addChildTo @
    @bg.x = @gridX.center()
    @bg.y = @gridY.center()

    label = phina.display.Label
      text: 'Menu1'
      stroke: false
    label.addChildTo @bg
    label = phina.display.Label
      text: 'Menu1'
      stroke: false
    label.addChildTo @bg
    return
