###*
* @file SceneBattleMoveCommand.coffee
* 移動コマンド
###

phina.define 'nz.SceneBattleMoveCommand',
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

    @setupKeyboradHander()
    @setupArrowKeyHandler (e) ->
      @mapSprite.fire e
      @_over @mapSprite.cursor
    @on 'input_enter', @_inputEnter
    @on 'input_escape', @_close

  _inputEnter: (e) ->
    @_end @mapSprite.cursor
    return

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

  _close: ->
    @mapSprite.clearBlink()
    @one 'enterframe', -> @app.popScene()
    return

  _end: (e) ->
    if @mapSprite.isBlink(e.mapx, e.mapy)
      @callback @searchRoute(e)
    @_close()
    return

  _over: (e) ->
    @mapSprite.clearBlink()
    c = @target.character
    if e.mapx is c.mapx and e.mapy is c.mapy
      return
    ap = c.getRemnantAp(@turn)
    route = @searchRoute(e)
    for r in route when r.cost <= ap
      @mapSprite.blink(r.mapx,r.mapy)
