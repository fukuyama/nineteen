###*
* @file SceneBattleTurn.coffee
* 戦闘ターン処理シーン
###

tm.define 'nz.SceneBattleTurn',
  superClass: nz.SceneBase

  init: (param) ->
    @superInit()
    {
      @mapSprite
      start
      end
    } = param
    @startTuen = start
    @endTurn   = end
    @turn      = start
    @runing    = false

    @_balletCount = 0

    @eventHandler = nz.EventHandlerBattle(scene:@)

    @on 'enter', @_startPhase
    @on 'addBallet', @_addBallet
    @on 'removeBallet', @_removeBallet

    return

  _removeBallet: (param) ->
    {
      ballet
    } = param
    @_balletCount -= 1

  _addBallet: (param) ->
    {
      ballet
      owner
    } = param
    @_balletCount += 1

    for c in @characterSprites when c != owner
      ballet.collision.add c

    # TODO: マップオブジェクトも追加しないと
    return

  _startPhase: ->
    @eventHandler.startBattlePhase()
    @_startTurn(@startTuen)
    return

  _endPhase: ->
    @eventHandler.endBattlePhase()
    @app.popScene()
    return

  _startTurn: (@turn) ->
    @eventHandler.startBattleTurn()
    @update = @updateTurn
    return

  _endTurn: ->
    @eventHandler.endBattleTurn()
    @update = null
    return

  _isEnd: -> @turn >= @endTurn

  _isEndAllCharacterAction: ->
    flag = false
    flag |= character.action for character in @characterSprites
    return (not flag) and (@_balletCount == 0)

  updateTurn: ->
    if @_isEndAllCharacterAction()
      @_endTurn()
      if @_isEnd()
        @_endPhase()
      else
        @_startTurn(@turn + 1)
    return

nz.SceneBattleTurn.prototype.getter 'characterSprites', -> @mapSprite.characterSprites
