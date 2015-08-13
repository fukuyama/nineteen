###*
* @file SceneBattleDirectionCommand.coffee
* 向き設定コマンドシーン
###

DIRECTIONS  = nz.system.character.directions

tm.define 'nz.SceneBattleDirectionCommand',
  superClass: nz.SceneBattleShotCommand

  init: (param) ->
    @superInit(param)

    @_direction = null
    @_keyRotate = @target.body.rotation
    @_keyRotateMult = 60

  _setupCommand: ->
    if @_direction?
      @callback(@target.direction,@_direction)
    return

  _rotatePointer: (rotation) ->
    return unless @pointer?
    console.log rotation
    for d,i in DIRECTIONS when 0 <= i and i < 6
      if d.rotation - 30 <= rotation and rotation <= d.rotation + 30
        costd = nz.Graph.directionCost(@target.direction, d.index)
        if (@costa + costd) <= @target.character.maxap
          if @_direction != d.index
            @_direction = d.index
            @pointer.rotation = d.rotation
            @_keyRotate = d.rotation
            return
    return

  _movePointer: (pointing) ->
    return unless @pointer?
    t = @target.body.localToGlobal tm.geom.Vector2(0,0)
    x = pointing.x - t.x
    y = pointing.y - t.y
    v = tm.geom.Vector2 x,y
    rotation = Math.radToDeg v.toAngle()
    for d,i in DIRECTIONS when 0 <= i and i < 6
      if d.rotation - 30 < rotation and rotation < d.rotation + 30
        costd = nz.Graph.directionCost(@target.direction, d.index)
        if (@costa + costd) <= @target.character.maxap
          if @_direction != d.index
            @_direction = d.index
            @pointer.rotation = d.rotation
            return
    return
