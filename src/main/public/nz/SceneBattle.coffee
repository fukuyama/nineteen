###*
* @file SceneBattle.coffee
* 戦闘シーン
###

SCREEN_W    = nz.system.screen.width
SCREEN_H    = nz.system.screen.height
DIRECTIONS  = nz.system.character.directions
ACTION_COST = nz.system.character.action_cost

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

    # ステータスフォルダ
    @status = tm.display.CanvasElement().addChildTo @

    x = y = 0
    for character,i in @characters
      # キャラクター
      @characterSprites.push nz.SpriteCharacter(i,character).addChildTo(@mapSprite)

      # ステータス
      s = nz.SpriteStatus i,character
      s.setPosition x, y
      s.on 'pointingend', (e) ->
        scene.activeStatus @
        scene.blinkCharacter @index
      @status.addChildAt s, 0
      y += 32 * 2.5 - 8

    # 基本操作
    @on 'map.pointingend', @mapPointingend
    @refreshStatus()
    return

  mapPointingend: (e) ->
    @mapSprite.clearBlink()
    list = @mapSprite.findCharacterGhost(e.mapx,e.mapy)
    for t in @mapSprite.findCharacter(e.mapx,e.mapy)
      if not t.ghost? or t.ghost.mapx != e.mapx or t.ghost.mapy != e.mapy
        list.push t
    targets = (t for t in list when not t.isGhost() or t.character.getRemnantAp(@turn) > 0)
    if targets.length == 0
      @_openMainMenu()
    else if targets.length == 1
      @_openCharacterMenu(targets[0])
    else
      @_openCharacterSelectMenu(targets)
    return

  refreshStatus: ->
    @fireAll('refreshStatus',turn:@turn)
    return

  activeStatus: (status) ->
    @status.addChild status
    return

  blinkCharacter: (index) ->
    s = @characterSprites[index]
    @mapSprite.clearBlink()
    @mapSprite.blink(s.mapx,s.mapy)
    if s.ghost?
      @mapSprite.blink(s.ghost.mapx,s.ghost.mapy)
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
    dlg.on 'menuclosed', (e) -> menuFunc[e.selectIndex]?.call(null,e.selectIndex)
    dlg.box.setStrokeStyle nz.system.dialog.strokeStyle
    dlg.box.setFillStyle   nz.system.dialog.fillStyle
    @app.pushScene dlg
    return dlg

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

  _openCharacterSelectMenu: (targets) ->
    menu     = []
    menuFunc = []
    for t in targets
      menu.push t.character.name
      menuFunc.push ((i) -> @_openCharacterMenu targets[i]).bind @
    menu.push 'Close Menu'
    @_openMenuDialog
      title: 'Select Character'
      menu: menu
      menuFunc: menuFunc
    return

  _openCharacterMenu: (target) ->
    @_selectCharacterIndex = target.index
    @_selectGhost          = target.isGhost()
    for s in @status.children when s.index == target.index
      @activeStatus s
    menu     = []
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

