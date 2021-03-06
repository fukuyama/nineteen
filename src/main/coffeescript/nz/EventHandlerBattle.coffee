###*
* @file EventHandlerBattle.coffee
* 戦闘用イベントハンドラ
###

phina.define 'nz.EventHandlerBattle',

  ###* 初期化
  * @classdesc 戦闘用イベントハンドラ
  * @constructor nz.EventHandlerBattle
  ###
  init: (scene)->
    @scene = scene

  _fireAll: (e,param={}) ->
    if typeof e is 'string'
      e       = {type:e}
      e.app   = @scene.app
      e.scene = @scene
      e.turn  = @scene.turn
      e.$extend param
    @_dispatchEvent(e,@scene)
    return

  _dispatchEvent: (e,element) ->
    if element.hasEventListener(e.type)
      element.fire(e)
    for child in element.children
      @_dispatchEvent(e,child) if child?
    return

  refreshStatus: ->
    @_fireAll('refreshStatus')
    return

  deadCharacter: (character) ->
    @_fireAll('deadCharacter',character:character)
    return

  startBattleScene: ->
    @_fireAll('startBattleScene')
    return

  endBattleScene: ->
    @_fireAll('endBattleScene')
    return

  replayBattle: ->
    @_fireAll('replayBattle')
    return

  startBattlePhase: ->
    @_fireAll('startBattlePhase')
    return

  endBattlePhase: ->
    @_fireAll('endBattlePhase')
    return

  startBattleTurn: ->
    @_fireAll('startBattleTurn')
    return

  endBattleTurn: ->
    @_fireAll('endBattleTurn')
    return

  addBallet: (param) ->
    @_fireAll('addBallet',param)
    return

  removeBallet: (param) ->
    @_fireAll('removeBallet',param)
    return

  selectStatus: (param) ->
    @_fireAll('selectStatus',param)
    return
