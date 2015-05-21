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

    @on 'enter', @_startScene

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

  _dispatchBattleEvent: (e,element=@) ->
    if typeof e is 'string'
      e      = tm.event.Event(e)
      e.app  = @app
      e.turn = @turn
    if element.hasEventListener(e.type)
      element.fire(e)
    for child in element.children
      @_dispatchBattleEvent(e,child)
    return

  _startScene: ->
    @_dispatchBattleEvent 'battleSceneStart'
    @_startTurn(@startTuen)
    return

  _endScene: ->
    @_dispatchBattleEvent 'battleSceneEnd'
    @app.popScene()
    return

  _startTurn: (@turn) ->
    @_dispatchBattleEvent 'battleTurnStart'
    @update = @updateTurn
    return

  _endTurn: ->
    @_dispatchBattleEvent 'battleTurnEnd'
    @update = null
    return

  _isEnd: -> @turn >= @endTurn

  _isEndAllCharacterAction: ->
    flag = false
    flag |= character.action for character in @characterSprites
    return (not flag) and (@_balletCount == 0)

  refreshStatus: ->
    @fireAll('refreshStatus',turn:@turn)
    return

  deadCharacter: (character) ->
    @fireAll('deadCharacter',character:character)
    return

  updateTurn: ->
    if @_isEndAllCharacterAction()
      @_endTurn()
      if @_isEnd()
        @_endScene()
      else
        @_startTurn(@turn + 1)
    return

nz.SceneBattleTurn.prototype.getter 'characterSprites', -> @mapSprite.characterSprites
