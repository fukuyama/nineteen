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
      @controlTeam
    } = param
    @superInit()
    @mapName = 'map_' + "#{@mapId}".paddingLeft(3,'0')
    @_selectCharacterIndex = 0

    @data =
      turn: 0 # 戦闘ターン数

    @on 'enter', @load.bind @
    return

  load: ->
    loaded = true
    assets = {}
    unless tm.asset.Manager.contains(@mapName)
      assets[@mapName] = "data/#{@mapName}.json"
      loaded = false
    for c in @characters when not tm.asset.Manager.contains(c.ai.name)
      assets[c.ai.name] = c.ai.src
      loaded = false

    unless loaded
      scene = tm.scene.LoadingScene(
        assets:  assets
        width:   SCREEN_W
        height:  SCREEN_H
        autopop: true
      )

      scene.on 'load', @setup.bind @

      @app.pushScene scene
    else
      @setup()
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
      @characterSprites.push(
        nz.SpriteCharacter(i,character)
          .setVisible(false)
          .addChildTo(@mapSprite)
      )

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

    @one 'enterframe', ->
      @_pushScene(
        nz.SceneBattlePosition(
          mapSprite: @mapSprite
          controlTeam: @controlTeam
        )
      )
      @one 'resume', -> @_startInputPhase()
    return

  mapPointingend: (e) ->
    @mapSprite.clearBlink()
    targets = @mapSprite.findCharacterGhost(e.mapx,e.mapy)
    for t in @mapSprite.findCharacter(e.mapx,e.mapy)
      if not t.hasGhost() or t.ghost.mapx != e.mapx or t.ghost.mapy != e.mapy
        targets.push t
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
    @mapSprite.blink(s.ghost.mapx,s.ghost.mapy) if s.hasGhost()
    return

  _pushScene: (scene) ->
    @one 'pause',  -> @mapSprite.addChildTo scene
    @one 'resume', -> @mapSprite.addChildTo @
    @mapSprite.remove()
    @app.pushScene scene
    return

  _commandScene: (klass,callback) ->
    @refreshStatus()
    target = @selectCharacterSprite
    if @_selectGhost
      target = @selectCharacterSprite.ghost
    @_pushScene klass(
      turn:      @turn
      target:    target
      callback:  callback
      mapSprite: @mapSprite
    )
    return

  _openMainMenu: ->
    @openMenuDialog
      title: 'Command?'
      menu: [
        {name:'Next Turn', func: @_openCommandConf.bind @}
        {name:'Option',    func: (e) -> return}
        {name:'Exit Game', func: @_exitGame.bind @}
        {name:'Close Menu'}
      ]
    return

  _openCharacterSelectMenu: (targets) ->
    menu = []
    for t in targets
      menu.push
        name: t.character.name
        func: ((i) -> @_openCharacterMenu targets[i]).bind @
    menu.push {name: 'Close Menu'}
    @openMenuDialog
      title: 'Select Character'
      menu: menu
    return

  _openCharacterMenu: (target) ->
    @_selectCharacterIndex = target.index
    @_selectGhost          = target.isGhost()
    @activeStatus(s) for s in @status.children when s.index == target.index
    menu  = []
    sc    = @selectCharacter
    acost = sc.getActionCost(@turn)
    rap   = sc.getRemnantAp(@turn)
    # アクションの入力が可能かどうか。（ゴーストを選択しているか、ゴーストを選択してない場合は、ゴーストを持っていなければ、入力可能）
    if @_selectGhost or (not @_selectGhost and not target.hasGhost())
      if rap > 0
        menu.push
          name: 'Move'
          func: @_addMoveCommand.bind @
        menu.push
          name: 'Direction'
          func: @_addRotateCommand.bind @
      if rap >= ACTION_COST.attack
        attack = sc.isAttackAction(@turn)
        shot   = sc.isShotAction(@turn)
        if not attack and not shot
          menu.push
            name: 'Attack'
            func: @_addAttackCommand.bind @
          menu.push
            name: 'Shot'
            func: @_addShotCommand.bind @
    if acost > 0
      menu.push
        name: 'Reset Action'
        func: @_resetAction.bind @
    menu.push {name:'Close Menu'}
    @openMenuDialog
      title: sc.name
      menu: menu
    return

  _openCommandConf: ->
    @openMenuDialog
      title: 'Start Battle?'
      menu: [
        {name:'Yes',func:@_startBattlePhase.bind @}
        {name:'No'}
      ]
    return

  _exitGame: ->
    @app.replaceScene nz.SceneTitleMenu()
    return

  _startInputPhase: () ->
    @data.turn += 1
    for c in @characters when not @controlTeam.contains c.team
      nz.system.ai[c.ai.name]?.setupAction(
        character: c
        characters: @characters
        graph: @mapSprite.graph
      )
    @refreshStatus()

  _startBattlePhase: ->
    @refreshStatus()
    @_pushScene(
      nz.SceneBattleTurn(
        start: @turn
        end: @turn
        mapSprite: @mapSprite
      )
    )
    @one 'resume', -> @_startInputPhase()
    return

  _addMoveCommand: ->
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
    sc = @selectCharacter
    sc.setAttackCommand @turn
    @refreshStatus()
    if sc.getRemnantAp(@turn) > 0
      @_selectGhost = true
      @one 'enterframe', @_addMoveCommand
    return

  _addShotCommand: ->
    @_commandScene(
      nz.SceneBattleShotCommand
      ((rotation) ->
        sc  = @selectCharacter
        scs = @selectCharacterSprite
        sc.addShotCommand @turn, rotation
        if not scs.hasGhost() and not scs.isGhost()
          scs.createGhost(scs.direction,scs.mapx,scs.mapy).addChildTo @mapSprite
        @refreshStatus()
        if sc.getRemnantAp(@turn) > 0
          @_selectGhost = true
          @one 'enterframe', @_addMoveCommand
        return
      ).bind @
    )
    return

  _addRotateCommand: ->
    @_commandScene(
      nz.SceneBattleDirectionCommand
      ((direction1,direction2) ->
        sc  = @selectCharacter
        scs = @selectCharacterSprite
        sc.addRotateCommand @turn, direction1, DIRECTIONS[direction1].rotateIndex[direction2]
        unless scs.hasGhost()
          s = scs
          s.createGhost(direction2,s.mapx,s.mapy).addChildTo @mapSprite
        else
          scs.ghost.setDirection(direction2)
        @refreshStatus()
        if sc.getRemnantAp(@turn) > 0
          @_selectGhost = true
          @one 'enterframe', @_addMoveCommand
        return
      ).bind @
    )
    return

  _resetAction: ->
    @selectCharacter.clearAction()
    @selectCharacterSprite.clearGhost()
    return

nz.SceneBattle.prototype.getter 'characterSprites', -> @mapSprite.characterSprites
nz.SceneBattle.prototype.getter 'selectCharacterSprite', -> @characterSprites[@_selectCharacterIndex]
nz.SceneBattle.prototype.getter 'selectCharacter', -> @selectCharacterSprite.character
nz.SceneBattle.prototype.getter 'turn', -> @data.turn
