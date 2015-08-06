

tm.define 'ScenePopMessage',

  superClass: 'tm.app.Scene'

  init: ->
    @superInit()
    @setInteractive(true)

    s = tm.display.RoundRectangleShape
      x: 640 / 2
      y: -60
      height: 120
      width: 320
      fillStyle: "gray"
    s.addChildTo @
    s.tweener
      .clear()
      .move(640 / 2, 960 / 2, 1000, 'swing')

    @on 'pointingend', (e) ->
      s.tweener
        .clear()
        .move(640 / 2, 960 + 60, 1000, 'swing')
        .call ((app) -> app.popScene()), @, [e.app]
