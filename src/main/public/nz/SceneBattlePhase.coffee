###*
* @file SceneBattlePhase.coffee
* 戦闘フェーズの処理
###

tm.define 'nz.SceneBattlePhase',
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

    @on 'map.pointingend', @_mapPointingend

    return

  _mapPointingend: ->
    console.log 'test'
    @_openReplayEndMenu()
    return

  _openReplayEndMenu: ->
    @openMenuDialog
      self: @
      title: 'Battle End'
      menu: [
        {name: 'Replay?',    func: @_startReplay}
        {name: 'Exit Game?', func: @_exitGame}
      ]
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
    flag |= c.action for c in @characterSprites when c.isAlive()
    return (not flag) and (@_balletCount == 0)

  updateTurn: ->
    if @_isEndAllCharacterAction()
      @_endTurn()
      if @_isEnd()
        @_endPhase()
      else
        @_startTurn(@turn + 1)
        if @_isEndAllCharacterAction()
          @_endTurn()
          @_endPhase()
    return

nz.SceneBattlePhase.prototype.getter 'characterSprites', -> @mapSprite.characterSprites
