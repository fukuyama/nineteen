###*
* @file SceneBattleMoveCommand.coffee
* 移動コマンド
###

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
