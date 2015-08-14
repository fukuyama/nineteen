###*
* @file SceneBattleDirectionCommand.coffee
* 向き設定コマンドシーン
###

DIRECTIONS  = nz.system.character.directions

tm.define 'nz.SceneBattleDirectionCommand',

  superClass: nz.SceneBattleRotatePointer

  init: (param) ->
    @superInit(param)

    @_remnant = @target.character.getRemnantAp(@turn)

    @_direction = @target.direction
    @_keyRotateMult = 60
    return

  _setupCommand: ->
    @callback(@target.direction,@_direction)
    return

  _rotatePointer: (rotation) ->
    return unless @pointer?
    rotation = nz.utils.normalizRotation rotation
    for d,i in DIRECTIONS when 0 <= i and i < 6
      if d.rotation - 30 <= rotation and rotation <= d.rotation + 30
        costd = nz.Graph.directionCost(@target.direction, d.index)
        if costd <= @_remnant
          if @_direction != d.index
            @_direction = d.index
            @pointer.rotation = d.rotation
            @_keyRotate = d.rotation
            return
    @_keyRotate = DIRECTIONS[@_direction].rotation
    return

  _movePointer: (pointing) ->
    return unless @pointer?
    t = @target.body.localToGlobal tm.geom.Vector2(0,0)
    x = pointing.x - t.x
    y = pointing.y - t.y
    v = tm.geom.Vector2 x,y
    @_rotatePointer Math.radToDeg v.toAngle()
    return
