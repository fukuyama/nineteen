###*
* @file SceneBattleCommand.coffee
* 戦闘コマンドシーン
###

DIRECTIONS  = nz.system.character.directions
ACTION_COST = nz.system.character.action_cost

tm.define 'nz.SceneBattleMoveCommand',
  superClass: tm.app.Scene

  init: (param) ->
    @superInit()
    {
      @turn
      @target
      @callback
      @mapSprite
    } = param

    @on 'map.pointingover', @_over
    @on 'map.pointingend', @_end

  searchRoute : (emapx, emapy)->
    {direction,mapx,mapy} = @target
    @mapSprite.graph.searchRoute(direction, mapx, mapy, emapx, emapy)

  commandAp: ->
    @target.character.ap - @target.character.getActionCost(@turn)

  _end: (e) ->
    if @mapSprite.isBlink(e.mapx, e.mapy)
      @callback @searchRoute(e.mapx, e.mapy)
    @mapSprite.clearBlink()
    @one 'enterframe', -> @app.popScene()
    return

  _over: (e) ->
    @mapSprite.clearBlink()
    ap = @commandAp()
    route = @searchRoute(e.mapx, e.mapy)
    for r in route
      if ap < r.cost
        break
      @mapSprite.blink(r.mapx,r.mapy)

tm.define 'nz.SceneBattleAttackCommand',
  superClass: nz.SceneBattleMoveCommand

  init: (param) ->
    @superInit(param)

  commandAp: ->
    @target.character.ap - @target.character.getActionCost(@turn) - ACTION_COST.attack

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

    @on 'map.pointingstart', @_pointStart
    @on 'pointingmove',      @_pointMove
    @on 'map.pointingend',   @_pointEnd
    @_createPointer()

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
      tcsr = @target.character.shot.rotation

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

tm.define 'nz.SceneBattleDirectionCommand',
  superClass: nz.SceneBattleShotCommand

  init: (param) ->
    @superInit(param)

    @_direction = null

  _setupCommand: ->
    if @_direction?
      @callback(@target.direction,@_direction)
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
        costd = nz.GridNode.calcDirectionCost(@target.direction, d.index)
        if (@costa + costd) <= @target.character.ap
          if @_direction != d.index
            @_direction = d.index
            @pointer.rotation = d.rotation
            return
    return
