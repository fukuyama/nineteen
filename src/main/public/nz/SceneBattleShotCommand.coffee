###*
* @file SceneBattleShotCommand.coffee
* 射撃コマンドシーン
###

tm.define 'nz.SceneBattleShotCommand',
  superClass: tm.app.Scene

  init: (param) ->
    @superInit()
    {
      @turn
      @target
      @callback
      @mapSprite
    } = param

    @costa = @target.character.getActionCost(@turn)

    #@on 'map.pointingstart', @_pointStart
    #@on 'map.pointingover', (e) ->
    #  @mapSprite.clearBlink()
    #  result = nz.utils.lineRoute(@target.character,e)
    #  for p in result
    #    @mapSprite.blink(p.mapx,p.mapy)
    #  return
    @on 'map.pointingend',   @_pointEnd
    @_createPointer()

  update: (app) ->
    @_movePointer(app.pointing)
    return

  _pointStart: (e) ->
    #@_removePointer()
    #@_createPointer()
    @_movePointer(e.pointing)
    return

  _pointMove: (e) ->
    @_movePointer(e.pointing)
    return

  _pointEnd: (e) ->
    @_setupCommand()
    @_removePointer()
    @_endScene()
    return

  _setupCommand: ->
    if @pointer?
      @callback(@pointer.rotation)
    return

  _endScene: ->
    @one 'enterframe', -> @app.popScene()
    return

  _createPointer: ->
    @pointer = tm.display.Shape(
      width: 10
      height: 10
    ).addChildTo @mapSprite
      .setPosition @target.x,@target.y
    tm.display.CircleShape(
      x: 40
      width: 10
      height: 10
      fillStyle: 'blue'
    ).addChildTo @pointer
    @pointer.rotation = @target.body.rotation
    return

  _removePointer: ->
    if @pointer?
      @pointer.remove()
      @pointer = null
    return

  _movePointer: (pointing) ->
    if @pointer?
      t    = @mapSprite.globalToLocal pointing
      tcsr = @target.character.shot.range

      @target.checkDirection(
        x:             t.x
        y:             t.y
        start:         tcsr.start
        end:           tcsr.end
        anticlockwise: tcsr.anticlockwise
        callback: ((result,r) ->
          if result
            x = t.x - @target.x
            y = t.y - @target.y
            v = tm.geom.Vector2 x,y
            r = Math.radToDeg v.toAngle()
          else
            r += @target.body.rotation
          @pointer.rotation = r
        ).bind @
      )
    return