###*
* @file SceneBattleShotCommand.coffee
* 射撃コマンドシーン
###

tm.define 'nz.SceneBattleShotCommand',

  superClass: nz.SceneBattleRotatePointer

  init: (param) ->
    @superInit(param)
    return

  _setupCommand: ->
    return unless @pointer?
    @callback(@pointer.rotation)
    return

  _rotatePointer: (r) ->
    return unless @pointer?
    tcsr = @target.character.shot.range

    r = nz.utils.relativeRotation(@target.body.rotation,r)
    @target.checkDirection(
      r:             r
      start:         tcsr.start
      end:           tcsr.end
      anticlockwise: tcsr.anticlockwise
      callback: ((result,ra) ->
        ra += @target.body.rotation
        unless result
          @_keyRotate = ra
        @pointer.rotation = ra
      ).bind @
    )
    return

  _movePointer: (pointing) ->
    return unless @pointer?
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
