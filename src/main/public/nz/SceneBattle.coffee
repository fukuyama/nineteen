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

  load: ->
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

  setup: ->
    scene = @

    # マップ
    @mapSprite = nz.SpriteBattleMap(@mapName).addChildTo(@)
    @mapSprite.x = (SCREEN_W - @mapSprite.width )
    @mapSprite.y = (SCREEN_H - @mapSprite.height) / 2

    @status = tm.display.CanvasElement().addChildTo @

    x = y = 0
    for character,i in @characters
      @characterSprites.push nz.SpriteCharacter(i,character).addChildTo(@mapSprite)
      s = nz.SpriteStatus i,character
      s.setPosition x, y
      s.on 'pointingend', (e) ->
        scene.activeStatus @
        scene.blinkCharacter @index
      @status.addChildAt s, 0
      y += 32 * 2.5 - 8

    # 基本操作
    @on 'character.pointingend', (e) ->
      @mapSprite.clearBlink()
      @_selectCharacterIndex = e.characterIndex
      @_selectGhost          = e.ghost
      for s in @status.children when s.index == e.characterIndex
        @activeStatus s
      @_openCharacterMenu()
    @on 'map.pointingend', (e) ->
      @mapSprite.clearBlink()
      target = @mapSprite.findCharacter(e.mapx,e.mapy)
      if target
        return
      target = @mapSprite.findCharacterGhost(e.mapx,e.mapy)
      if target
        if target.character.getActionCost(@turn) < target.character.ap
          return
      @_openMainMenu()
    @refreshStatus()
    return

  refreshStatus: ->
    @fireAll('refreshStatus',turn:@turn)
    return

  blinkCharacter: (index) ->
    s = @characterSprites[index]
    @mapSprite.clearBlink()
    @mapSprite.blink(s.mapx,s.mapy)
    if s.ghost?
      @mapSprite.blink(s.ghost.mapx,s.ghost.mapy)
    return

  activeStatus: (status) ->
    @status.addChild status
    return

  _commandScene: (klass,callback) ->
    @refreshStatus()
    target = @selectCharacterSprite
    if @_selectGhost
      target = @selectCharacterSprite.ghost
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

  _openMenuDialog: (_param) ->
    param = {
      screenWidth:  SCREEN_W
      screenHeight: SCREEN_H
    }.$extend _param
    menuFunc = param.menuFunc
    dlg = tm.ui.MenuDialog(param)
    dlg.on 'menuclosed', (e) -> menuFunc[e.selectIndex]?.call(null)
    dlg.box.setStrokeStyle nz.system.dialog.strokeStyle
    dlg.box.setFillStyle   nz.system.dialog.fillStyle
    @app.pushScene dlg
    return

  _openMainMenu: ->
    @_openMenuDialog
      title: 'Command?'
      menu: ['Next Turn','Option','Exit Game','Close Menu']
      menuFunc: [
        @_openCommandConf.bind @
        (e) -> return
        (e) -> @app.replaceScene nz.SceneTitleMenu()
      ]
    return

  _openCharacterMenu: ->
    menu = []
    menuFunc = []
    sc     = @selectCharacter
    ap     = sc.ap
    cost   = sc.getActionCost(@turn)
    attack = sc.isAttackAction(@turn)
    shot   = sc.isShotAction(@turn)
    if (ap - cost) >= 1 or not @_selectGhost
      menu.push 'Move'
      menuFunc.push @_addMoveCommand.bind @
      menu.push 'Direction'
      menuFunc.push @_addRotateCommand.bind @
    if not shot
      if (ap - cost) >= 2
        if not attack
          menu.push 'Attack'
          menuFunc.push @_addAttackCommand.bind @
        if cost == 0 or @_selectGhost
          menu.push 'Shot'
          menuFunc.push @_addShotCommand.bind @
    menu.push 'Close Menu'
    @_openMenuDialog
      title: sc.name
      menu: menu
      menuFunc: menuFunc
    return

  _openCommandConf: ->
    @_openMenuDialog
      title: 'Start Next Turn?'
      menu: ['Yes','No']
      menuFunc: [
        @_nextTurn.bind @
      ]
    return

  _nextTurn: ->
    @refreshStatus()
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
      @refreshStatus()
      return
    @mapSprite.remove()
    @app.pushScene scene
    return

  _addMoveCommand: ->
    unless @_selectGhost
      # ゴーストを選択してない場合は、移動アクションを削除して、ゴーストも削除
      @selectCharacter.clearMoveAction(@turn)
      @selectCharacterSprite.clearGhost()
    @_commandScene(
      nz.SceneBattleMoveCommand
      ((route) ->
        @selectCharacter.addMoveCommand @turn, route
        if route.length > 0
          p = route[route.length-1]
          @selectCharacterSprite.createGhost(p.direction,p.mapx,p.mapy).addChildTo @mapSprite
        @refreshStatus()
        return
      ).bind @
    )
    return

  _addAttackCommand: ->
    @selectCharacter.setAttackCommand @turn
    @refreshStatus()
    return

  _addShotCommand: ->
    unless @_selectGhost
      # ゴーストを選択してない場合は、移動アクションを削除して、ゴーストも削除
      @selectCharacter.clearMoveAction(@turn)
      @selectCharacterSprite.clearGhost()
    @_commandScene(
      nz.SceneBattleShotCommand
      ((rotation) ->
        @selectCharacter.addShotCommand @turn, rotation
        unless @selectCharacterSprite.ghost?
          s = @selectCharacterSprite
          s.createGhost(s.direction,s.mapx,s.mapy).addChildTo @mapSprite
        @refreshStatus()
        return
      ).bind @
    )
    return

  _addRotateCommand: ->
    unless @_selectGhost
      # ゴーストを選択してない場合は、移動アクションを削除して、ゴーストも削除
      @selectCharacter.clearMoveAction(@turn)
      @selectCharacterSprite.clearGhost()
    @_commandScene(
      nz.SceneBattleDirectionCommand
      ((direction1,direction2) ->
        @selectCharacter.addRotateCommand @turn, direction1, DIRECTIONS[direction1].rotateIndex[direction2]
        unless @selectCharacterSprite.ghost?
          s = @selectCharacterSprite
          s.createGhost(direction2,s.mapx,s.mapy).addChildTo @mapSprite
        else
          @selectCharacterSprite.ghost.setDirection(direction2)
        @refreshStatus()
        return
      ).bind @
    )
    return

nz.SceneBattle.prototype.getter 'characterSprites', -> @mapSprite.characterSprites
nz.SceneBattle.prototype.getter 'selectCharacterSprite', -> @characterSprites[@_selectCharacterIndex]
nz.SceneBattle.prototype.getter 'selectCharacter', -> @selectCharacterSprite.character
nz.SceneBattle.prototype.getter 'turn', -> @data.turn

