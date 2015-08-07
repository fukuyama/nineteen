###*
* @file ScenePopMessage.coffee
* POP Message シーン
###

tm.define 'nz.ScenePopMessage',

  superClass: 'tm.app.Scene'

  init: (param) ->
    {
      width
      height
      start
      center
      end
      duration
      easing
      fillStyle
      strokeStyle
      message
    } = {
      width:  200
      height: 50
      start:  [100,-25]
      center: [100,100]
      end:    [100,-25]
      duration: 1000
      easing: 'swing'
      fillStyle: 'gray'
      strokeStyle: 'gray'
      message:     '(test message)'
    }.$extend param

    @_param = {
      start:
        x:        start[0]
        y:        start[1]
      center:
        x:        center[0]
        y:        center[1]
        duration: center[2] ? duration
        easing:   center[3] ? easing
      end:
        x:        end[0]
        y:        end[1]
        duration: end[2]    ? duration
        easing:   end[3]    ? easing
    }

    @superInit()
    @setInteractive(true)

    {x,y} = @_param.start
    @_board = tm.display.RoundRectangleShape
      x:           x
      y:           y
      height:      height
      width:       width
      fillStyle:   fillStyle
      strokeStyle: strokeStyle
    @_board.addChildTo @

    @_label = tm.display.Label message
    @_label.addChildTo @_board

    @on 'pointingend', -> @outAnimation()
    @on 'enter', -> @inAnimation()

  inAnimation: ->
    {x,y,duration,easing} = @_param.center
    @_board.tweener
      .clear()
      .move(x,y,duration,easing)

  outAnimation: ->
    {x,y,duration,easing} = @_param.end
    @_board.tweener
      .clear()
      .move(x,y,duration,easing)
      .call (-> @app.popScene()), @, []
