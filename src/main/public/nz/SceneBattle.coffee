###*
* @file SceneBattle.coffee
* 戦闘シーン
###

SCREEN_W    = nz.system.screen.width
SCREEN_H    = nz.system.screen.height
DIRECTIONS  = nz.system.character.directions
ACTION_COST = nz.system.character.action_cost

tm.define 'nz.SceneBase',
  superClass: tm.app.Scene

  init: ->
    @superInit()
    return

  fireAll: (e,param={}) ->
    if typeof e is 'string'
      e      = tm.event.Event(e)
      e.app  = @app
      e.$extend param
    @_dispatchEvent(e)
    return

  _dispatchEvent: (e,element=@) ->
    if element.hasEventListener(e.type)
      element.fire(e)
    for child in element.children
      @_dispatchEvent(e,child)
    return

tm.define 'nz.SceneBattle',
  superClass: nz.SceneBase

  ###* 初期化
  * @classdesc 戦闘シーンクラス
  * @constructor nz.SceneBattle
  ###
  init: (param) ->
    {
      @mapId
      @characters
    } = param
    @superInit()
    @mapName = 'map_' + "#{@mapId}".paddingLeft(3,'0')
    @_selectCharacterIndex = 0

    @data =
      turn: 0 # 戦闘ターン数

    @on 'enter', @load.bind @
    return

  load: () ->
    assets = {}
    assets[@mapName] = "data/#{@mapName}.json"

    scene = tm.scene.LoadingScene(
      assets:  assets
      width:   SCREEN_W
      height:  SCREEN_H
      autopop: true
    )

    scene.on 'load', @setup.bind @

    @app.pushScene scene
    return

  setup: () ->

    # マップ
    @mapSprite = nz.SpriteBattleMap(@mapName).addChildTo(@)
    @mapSprite.x = (SCREEN_W - @mapSprite.width )
    @mapSprite.y = (SCREEN_H - @mapSprite.height) / 2

    x = y = 0
    for character,i in @characters
      @characterSprites.push nz.SpriteCharacter(i,character).addChildTo(@mapSprite)
      nz.SpriteStatus(
        character: character
        battleData: @data
      ).addChildTo @
        .setPosition x, y
      y += 32 * 2.5

    # 基本操作
    @on 'character.pointingend', (e) ->
      @_selectCharacterIndex = e.characterIndex
      @_selectGhost          = e.ghost
      @_openCharacterMenu()
    @on 'map.pointingend', (e) ->
      target = @mapSprite.findCharacter(e.mapx,e.mapy)
      if target
        if target.character.getActionCost(@turn) < target.character.ap
          return
      @_openMainMenu()
    @refreshStatus()
    return

  refreshStatus: ->
    @fireAll('refreshStatus',turn:@turn)
    return

  _commandScene: (klass,callback) ->
    target = @selectCharacterSprite
    if @_selectGhost
      target = @selectCharacterSprite.ghost
    else
      @selectCharacter.clearAction(@turn)
    scene = klass(
      turn:      @turn
      target:    target
      callback:  callback
      mapSprite: @mapSprite
    )
    @one 'pause',  -> @mapSprite.addChildTo scene
    @one 'resume', -> @mapSprite.addChildTo @
    @mapSprite.remove()
    @app.pushScene scene
    return

  _createMenuDialog: (_param) ->
    param = {
      screenWidth:  SCREEN_W
      screenHeight: SCREEN_H
    }.$extend _param
    menuFunc = param.menuFunc
    dlg = tm.ui.MenuDialog(param)
    dlg.on 'menuclosed', (e) -> menuFunc[e.selectIndex]?.call(null)
    dlg.box.setStrokeStyle nz.system.dialog.strokeStyle
    dlg.box.setFillStyle   nz.system.dialog.fillStyle
    return dlg

  _openMainMenu: ->
    @app.pushScene @_createMenuDialog(
      title: 'Command?'
      menu: ['Next Turn','Option','Exit Game','Close Menu']
      menuFunc: [
        @_openCommandConf.bind @
        -> return
        (e) -> e.app.replaceScene nz.SceneTitleMenu()
      ]
    )

  _openCharacterMenu: ->
    self = @
    menu = []
    menuFunc = []
    ap = @selectCharacter.ap - @selectCharacter.getActionCost(@turn)
    if ap >= 1
      menu.push 'Move'
      menuFunc.push -> self._commandScene nz.SceneBattleMoveCommand, self._addMoveCommand.bind self
      menu.push 'Direction'
      menuFunc.push -> self._commandScene nz.SceneBattleDirectionCommand, self._addRotateCommand.bind self
    if ap >= 2
      menu.push 'Attack'
      menuFunc.push -> self._addAttackCommand()
      if @selectCharacter.isShotAction(@turn)
        menu.push 'Shot'
        menuFunc.push -> self._commandScene nz.SceneBattleShotCommand, self._addShotCommand.bind self
    menu.push 'Close Menu'
    @app.pushScene @_createMenuDialog(
      title: @selectCharacter.name
      menu: menu
      menuFunc: menuFunc
    )

  _openCommandConf: ->
    @app.pushScene @_createMenuDialog(
      title: 'Start Next Turn?'
      menu: ['Yes','No']
      menuFunc: [
        @_nextTurn.bind @
      ]
    )

  _nextTurn: ->
    scene = nz.SceneBattleTurn
      start: @turn
      end: @turn
      mapSprite: @mapSprite
    @one 'pause', ->
      @mapSprite.addChildTo scene
      return
    @one 'resume', ->
      @mapSprite.addChildTo @
      @data.turn += 1
      return
    @mapSprite.remove()
    @app.pushScene scene
    return


  _addMoveCommand: (route) ->
    @selectCharacter.addMoveCommand @turn, route
    if route.length > 0
      p = route[route.length-1]
      @selectCharacterSprite.createGhost(p.direction,p.mapx,p.mapy).addChildTo @mapSprite
    @refreshStatus()
    return

  _addAttackCommand: ->
    @selectCharacter.setAttackCommand @turn
    @refreshStatus()
    return

  _addShotCommand: (rotation) ->
    @selectCharacter.addShotCommand @turn, rotation
    unless @selectCharacterSprite.ghost?
      s = @selectCharacterSprite
      s.createGhost(s.direction,s.mapx,s.mapy).addChildTo @mapSprite
    @refreshStatus()
    return

  _addRotateCommand: (direction1,direction2) ->
    @selectCharacter.addRotateCommand @turn, direction1, DIRECTIONS[direction1].rotateIndex[direction2]
    unless @selectCharacterSprite.ghost?
      s = @selectCharacterSprite
      s.createGhost(direction2,s.mapx,s.mapy).addChildTo @mapSprite
    else
      @selectCharacterSprite.ghost.setDirection(direction2)
    @refreshStatus()
    return


nz.SceneBattle.prototype.getter 'characterSprites', -> @mapSprite.characterSprites
nz.SceneBattle.prototype.getter 'selectCharacterSprite', -> @characterSprites[@_selectCharacterIndex]
nz.SceneBattle.prototype.getter 'selectCharacter', -> @selectCharacterSprite.character
nz.SceneBattle.prototype.getter 'turn', -> @data.turn

