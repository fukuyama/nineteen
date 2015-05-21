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
      @characters
    } = param

    @on 'map.pointingover', @_over
    @on 'map.pointingend', @_end

  searchRoute: (e)->
    op = {
      graph:
        cost: @target.character.getRemnantAp(@turn)
    }
    r = nz.utils.searchRoute(
      @mapSprite.graph
      @target
      e
      @characters
      op
    )
    return r

  _end: (e) ->
    if @mapSprite.isBlink(e.mapx, e.mapy)
      @callback @searchRoute(e)
    @mapSprite.clearBlink()
    @one 'enterframe', -> @app.popScene()
    return

  _over: (e) ->
    @mapSprite.clearBlink()
    ap = @target.character.getRemnantAp(@turn)
    route = @searchRoute(e)
    for r in route when r.cost <= ap
      @mapSprite.blink(r.mapx,r.mapy)
