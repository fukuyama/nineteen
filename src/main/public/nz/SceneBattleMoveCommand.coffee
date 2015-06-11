###*
* @file SceneBattleMoveCommand.coffee
* 移動コマンド
###

tm.define 'nz.SceneBattleMoveCommand',
  superClass: nz.SceneBase

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

    @on 'enterframe'   , @createKeyboradHander()
    @setupCursorHandler (e) ->
      @mapSprite.fire e
      @_over @mapSprite.cursor
    @on 'input_enter'  , @inputEnter

  inputEnter: (e) ->
    @_end @mapSprite.cursor

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
