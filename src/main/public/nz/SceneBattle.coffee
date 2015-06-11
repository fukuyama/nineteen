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
      @endCondition
    } = param
    @superInit()
    @mapName = 'map_' + "#{@mapId}".paddingLeft(3,'0')
    @_selectCharacterIndex = 0

    unless @endCondition?
      @endCondition =
        type: 'team'
        turn: 20

    @data =
      turn: 0 # 戦闘ターン数

    @eventHandler = nz.EventHandlerBattle(scene:@)

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
      scene = tm.game.LoadingScene(
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
      s = nz.SpriteStatus(
        index: i
        character: character
        detail: @controlTeam.contains character.team
      )
      s.setPosition x, y
      s.on 'pointingend', (e) ->
        scene.activeStatus @
        scene.blinkCharacter @index
      @status.addChildAt s, 0
      y += 32 * 2.5 - 8

    # 基本操作
    @on 'map.pointingend', @_mapPointingend

    # 開始時位置決め
    @one 'enterframe', ->
      @_pushScene(
        nz.SceneBattlePosition(
          mapSprite: @mapSprite
          controlTeam: @controlTeam
        )
      )
      @one 'resume', -> @_startInputPhase()

    @eventHandler.refreshStatus()

    @on 'enterframe'   , @createKeyboradHander()
    @on 'input_enter'  , @inputEnter
    @setupCursorHandler @cursorHandler
    return

  cursorHandler: (e) ->
    @mapSprite.fire e

  inputEnter: (e) ->
    @_mapPointingend @mapSprite.cursor

  _mapPointingend: (param) ->
    {
      mapx
      mapy
    } = param
    @mapSprite.clearBlink()
    targets = @mapSprite.findCharacterGhost(mapx,mapy)
    for t in @mapSprite.findCharacter(mapx,mapy) when t.isAlive()
      if not t.hasGhost() or t.ghost.mapx != mapx or t.ghost.mapy != mapy
        targets.push t
    targets = (t for t in targets when @controlTeam.contains t.character.team)
    if targets.length == 0
      @_openMainMenu()
    else if targets.length == 1
      @_openCharacterMenu(targets[0])
    else
      @_openCharacterSelectMenu(targets)
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

  isEnd: ->
    if @turn >= @endCondition.turn
      return true
    if @endCondition.type is 'team'
      t = null
      for c in @characters when c.isAlive()
        unless t?
          t = c.team
        else if t isnt c.team
          return false
      return true
    return false

  _pushScene: (scene) ->
    @eventHandler.refreshStatus()
    @one 'pause',  ->
      @mapSprite.addChildTo scene
      @status.addChildTo scene
      return
    @one 'resume', ->
      @mapSprite.addChildTo @
      @status.addChildTo @
      @eventHandler.refreshStatus()
      return
    @mapSprite.remove()
    @status.remove()
    @app.pushScene scene
    return

  _commandScene: (klass,callback) ->
    target = @selectCharacterSprite
    if @_selectGhost
      target = @selectCharacterSprite.ghost
    @_pushScene klass(
      turn:       @turn
      target:     target
      callback:   callback
      mapSprite:  @mapSprite
      characters: @characters
    )
    @one 'resume', @_checkCommandConf.bind @
    return

  _openMainMenu: ->
    @openMenuDialog
      self: @
      title: 'Command?'
      menu: [
        {name:'Next Turn', func: @_openCommandConf}
        {name:'Option',    func: -> return}
        {name:'Exit Game', func: @_exitGame}
        {name:'Close Menu'}
      ]
    return

  _openCharacterSelectMenu: (targets) ->
    menu = []
    for t in targets
      menu.push
        name: t.character.name
        func: (i) -> @_openCharacterMenu targets[i]
    menu.push {name: 'Close Menu'}
    @openMenuDialog
      self: @
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
          func: @_addMoveCommand
        menu.push
          name: 'Direction'
          func: @_addRotateCommand
      if rap >= ACTION_COST.attack
        attack = sc.isAttackCommand(@turn)
        shot   = sc.isShotCommand(@turn)
        if not attack and not shot
          menu.push
            name: 'Attack'
            func: @_addAttackCommand
          menu.push
            name: 'Shot'
            func: @_addShotCommand
    if acost > 0
      menu.push
        name: 'Reset Action'
        func: @_resetCommand
    menu.push {name:'Close Menu'}
    @openMenuDialog
      self: @
      title: sc.name
      menu: menu
    return

  _openCommandConf: ->
    @openMenuDialog
      self: @
      title: 'Start Battle?'
      menu: [
        {name:'Yes',func:@_startBattlePhase}
        {name:'No'}
      ]
    return

  _checkCommandConf: ->
    for c in @characters when @controlTeam.contains(c.team) and c.isAlive()
      if c.getRemnantAp(@turn) > 0
        return
    @_openCommandConf()
    return

  _openResult: ->
    @_pushScene(
      nz.SceneBattleResult(
        mapSprite: @mapSprite
        status: @status
      )
    )
    ###
    @openMenuDialog
      self: @
      title: 'Battle End'
      menu: [
        {name: 'Replay',    func: @_startReplay}
        {name: 'Exit Game', func: @_exitGame}
      ]
    ###
    return

  _exitGame: ->
    @app.replaceScene nz.SceneTitleMenu()
    return

  _startInputPhase: () ->
    @data.turn += 1
    characters = (c.createAiInfo() for c in @characters)
    for c,i in characters when not (@controlTeam.contains c.team) and c.isAlive()
      nz.system.ai[c.ai.name]?.setupAction new nz.ai.Param(
        character: c
        characters: characters
        graph: @mapSprite.graph
        turn: @turn
      )
      @characters[i].commands[@turn] = c.commands[@turn]
    @eventHandler.refreshStatus()

  _startBattlePhase: ->
    @_pushScene(
      nz.SceneBattlePhase(
        start: @turn
        end: @turn
        mapSprite: @mapSprite
        status: @status
      )
    )
    @one 'resume', ->
      if @isEnd()
        @_openResult()
      else
        @_startInputPhase()
    return

  _addMoveCommand: ->
    @_commandScene(
      nz.SceneBattleMoveCommand
      ((route) ->
        sc = @selectCharacter
        sc.addMoveCommand @turn, route
        if route.length > 0
          @selectCharacterSprite.createGhost(route[route.length-1]).addChildTo @mapSprite
        if sc.getRemnantAp(@turn) > 0
          @_selectGhost = true
          @one 'enterframe', @_addRotateCommand
        return
      ).bind @
    )
    return

  _addAttackCommand: ->
    sc = @selectCharacter
    sc.setAttackCommand @turn
    scs = @selectCharacterSprite
    if not scs.hasGhost() and not scs.isGhost()
      scs.createGhost(scs).addChildTo @mapSprite
    @eventHandler.refreshStatus()
    if sc.getRemnantAp(@turn) > 0
      @_selectGhost = true
      @one 'enterframe', @_addMoveCommand
    else
      @_checkCommandConf()
    return

  _addShotCommand: ->
    @_commandScene(
      nz.SceneBattleShotCommand
      ((rotation) ->
        sc  = @selectCharacter
        scs = @selectCharacterSprite
        sc.addShotCommand @turn, rotation
        if not scs.hasGhost() and not scs.isGhost()
          scs.createGhost(scs).addChildTo @mapSprite
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
          scs.createGhost(scs).addChildTo @mapSprite
        scs.ghost.setDirection(direction2)
        return
      ).bind @
    )
    return

  _resetCommand: ->
    @selectCharacter.clearCommand()
    @selectCharacterSprite.clearGhost()
    @eventHandler.refreshStatus()
    return

nz.SceneBattle.prototype.getter 'characterSprites', -> @mapSprite.characterSprites
nz.SceneBattle.prototype.getter 'selectCharacterSprite', -> @characterSprites[@_selectCharacterIndex]
nz.SceneBattle.prototype.getter 'selectCharacter', -> @selectCharacterSprite.character
nz.SceneBattle.prototype.getter 'turn', -> @data.turn
