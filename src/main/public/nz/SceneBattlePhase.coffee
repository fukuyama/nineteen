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
      @status
      start
      end
    } = param
    @startTuen = start
    @endTurn   = end
    @turn      = start

    @_balletCount = 0

    @eventHandler = nz.EventHandlerBattle()

    @on 'enter', @_startPhase
    @on 'addBallet', @_addBallet
    @on 'removeBallet', @_removeBallet

    @on 'map.pointingend', @_openPauseMenu

    @on 'enterframe'   , @createKeyboradHander()
    @on 'input_enter'  , @_openPauseMenu

    @on 'selectStatus', (e) ->
      {
        scene
        status
      } = e
      scene.activeStatus status

    return

  activeStatus: (status) ->
    @status.addChild status
    return

  _openPauseMenu: ->
    @openMenuDialog
      self: @
      title: 'Pause'
      menu: [
        {name: 'Continue',   func: -> return }
        {name: 'Exit Game?', func: @_exitGame}
      ]
    return

  _exitGame: (e) ->
    app = @app ? e.app
    app.popScene()
    nz.system.restart()
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
    flag = @characterSprites
      .filter (c) -> c.isAlive()
      .some (c) -> c.action
    #flag = false
    #flag |= c.action for c in @characterSprites when c.isAlive()
    return (not flag) and (@_balletCount is 0)

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
