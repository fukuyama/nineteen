###*
* @file SceneBattle.coffee
* 戦闘シーン
###

SCREEN_W    = nz.system.screen.width
SCREEN_H    = nz.system.screen.height
DIRECTIONS  = nz.system.character.directions
ACTION_COST = nz.system.character.action_cost
MSGS        = nz.system.messages
MCD         = MSGS.battle.command

phina.define 'nz.SceneBattle',
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
      @teams
    } = param
    @superInit()
    @eventHandler = nz.EventHandlerBattle(@)
    @preLoad()
    return

  _init: ->
    @_selectCharacterIndex = 0

    unless @endCondition?
      @endCondition =
        type: 'team'
        turn: 20

    teams = @controlTeam.clone()
    for c,i in @characters
      unless c instanceof nz.Character
        @characters[i] = new nz.Character(c)
      unless teams.contains c.team
        teams.push c.team

    @data =
      turn:   0    # 戦闘ターン数
      winner: null
      replay: null
      startInfo: {}
      teams: teams

    @eventHandler = nz.EventHandlerBattle(@)
    return

  preLoad: ->
    @mapName = 'map_' + "#{@mapId}".paddingLeft(3,'0')

    json = {}
    json[@mapName] = "/maps/#{@mapId}"
    for c,i in @characters when typeof c is 'number'
      k = 'character_' + "#{c}".paddingLeft(3,'0')
      json[k] = "/characters/#{c}"

    @loadAsset {json:json}, @preLoaded
    return

  preLoaded: ->
    # マップ
    @mapSprite = nz.SpriteBattleMap(@mapName).addChildTo @

    # キャラクターデータ取得
    for c,i in @characters when typeof c is 'string'
      @characters[i] = new nz.Character @asset('json',c).data
    for c,i in @characters when not (c instanceof nz.Character) and typeof c is 'object'
      @characters[i] = new nz.Character c

    # キャラクタースプライトの作成
    for c,i in @characters
      @mapSprite.addCharacter nz.SpriteCharacter(i,c)

    # チーム分け
    if @teams?
    else
      @teams = {}
      for c,i in @characters
        team = c.team
        @teams[team] = [] unless @teams[team]?
        @teams[team].push c

    @setupKeyboradHander()
    @setupArrowKeyHandler (e) -> @mapSprite.cursor.fire e

    @app.pushScene nz.SceneBattlePosition @
    return

  setup: ->
    console.log 'setup'
    scene = @

    # ステータスフォルダ
    @status = phina.display.CanvasElement().addChildTo @

    ###
    x = y = 0
    for character,i in @characters
      # キャラクター
      sprite = nz.SpriteCharacter(i,character)
        .setVisible(false)
        .addChildTo(@mapSprite)
      @characterSprites.push sprite

      # ステータス
      s = nz.SpriteStatus(
        index: i
        character: character
        characterSprite: sprite
        detail: @controlTeam.contains character.team
      )
      s.setPosition x, y
      @status.addChildAt s, 0
      y += 32 * 2.5 - 8
    ###

    @on 'selectStatus', (e) ->
      {
        scene
        status
      } = e
      scene.activeStatus status
      scene.blinkCharacter status.index

    # 開始時位置決め
    @one 'enterframe', ->
      @pushScene nz.SceneBattlePosition
        mapSprite:   @mapSprite
        controlTeam: @controlTeam
      @one 'resume', ->
        @eventHandler.startBattleScene()

    @one 'startBattleScene', ->
      # 基本操作
      @on 'map.pointingend', @_mapPointingend
      # イベント
      @setupKeyboradHander()
      @on 'input_enter'  , @inputEnter
      @setupArrowKeyHandler @cursorHandler

      @data.startInfo.characters = []
      for c in @characters
        @data.startInfo.characters.push
          mapx:      c.mapx
          mapy:      c.mapy
          direction: c.direction
          hp:        c.hp
          sp:        c.sp
      @_startInputPhase()
      return

    @eventHandler.refreshStatus()
    return

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
      @_openGameMenu()
    else if targets.length == 1
      @_openCommandMenu(targets[0])
    else
      @_openSelectCharacterMenu(targets)
    return

  activeStatus: (status) ->
    @status.addChild status
    return

  blinkCharacter: (index) ->
    s = @characterSprites[index]
    @mapSprite.clearBlink()
    if s.isAlive()
      @mapSprite.blink(s.mapx,s.mapy)
      @mapSprite.blink(s.ghost.mapx,s.ghost.mapy) if s.hasGhost()
    return

  _createResultTimeup: ->
    name = ''
    score = 0
    t = {}
    for c in @characters when c.isAlive()
      unless t[c.team]?
        t[c.team] = c.hp
      else
        t[c.team] += c.hp
      if score < t[c.team]
        name  = c.team
        score = t[c.team]
    winner = [
      {
        name: name
        score: score
      }
    ]
    for k,v of t when name isnt k and score is v
      winner.push
        name: k
        score: v
    if winner.length is 1
      @data.result =
        winner: winner[0]
    else
      @data.result =
        draw: winner
    return

  _createResultTeam: ->
    # １チームが残っている場合に終了
    t = null
    for c in @characters when c.isAlive()
      unless t?
        t = c.team
      else if t isnt c.team
        return
    @data.result = {
      winner:
        name: t
    }
    return

  _createResult: ->
    # 時間切れの場合
    if @turn >= @endCondition.turn
      @_createResultTimeup()
      return
    # 終了タイプがチームの場合
    if @endCondition.type is 'team'
      @_createResultTeam()
      return
    return

  isEnd: -> @data.result?

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
    @descriptionOff()
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
      status:     @status
      characters: @characters
    )
    @one 'resume', @_checkCommandConf.bind @
    return

  _openGameMenu: ->
    @openMenuDialog
      self: @
      title: 'Command?'
      menu: [
        {name:'Next Turn'  , func: @_openTurnConfMenu, description: MCD.next_turn }
        {name:'Option'     , func: @_option          , description: MCD.option    }
        {name:'Exit Game'  , func: @_exitGame        , description: MCD.exit_game }
        {name:'Close Menu'                           , description: MCD.close_menu}
      ]
    return

  _openSelectCharacterMenu: (targets) ->
    menu = []
    for t in targets
      menu.push
        name: t.character.name
        func: (i) -> @_openCommandMenu targets[i]
        description: t.character.name + 'を選択。'
    menu.push {name: 'Close Menu',description: MCD.close_menu}
    @openMenuDialog
      self: @
      title: 'Select Character'
      menu: menu
    return

  _openCommandMenu: (target) ->
    @_selectCharacterIndex = target.index
    @_selectGhost          = target.isGhost()
    @activeStatus(s) for s in @status.children when s.index == target.index
    menu  = []
    sc    = @selectCharacter
    acost = sc.getActionCost(@turn)
    rap   = sc.getRemnantAp(@turn)
    # アクションの入力が可能かどうか。（ゴーストを選択しているか、ゴーストを選択してない場合は、ゴーストを持っていなければ、入力可能）
    if @_selectGhost or (not @_selectGhost and not target.hasGhost())
      if rap >= ACTION_COST.move
        menu.push
          name: 'Move'
          description: MSGS.battle.command.move
          func: @_addMoveCommand
      if rap >= ACTION_COST.rotate
        menu.push
          name: 'Rotate'
          description: MSGS.battle.command.rotate
          func: @_addRotateCommand
      if rap >= ACTION_COST.attack
        attack = sc.isAttackCommand(@turn)
        shot   = sc.isShotCommand(@turn)
        if not attack and not shot
          menu.push
            name: 'Attack'
            description: MSGS.battle.command.attack
            func: @_addAttackCommand
          menu.push
            name: 'Shot'
            description: MSGS.battle.command.shot
            func: @_addShotCommand
    if acost > 0
      menu.push
        name: 'Reset Action'
        description: MSGS.battle.command.reset
        func: @_resetCommand
    menu.push {name:'Close Menu'}
    @openMenuDialog
      self: @
      title: sc.name
      menu: menu
    return

  _openTurnConfMenu: ->
    @openMenuDialog
      self: @
      title: 'Start Battle?'
      menu: [
        {name:'Yes',func: -> @_startBattlePhase() }
        {name:'No'}
      ]
    return

  _checkCommandConf: ->
    for c in @characters when @controlTeam.contains(c.team) and c.isAlive()
      if c.getRemnantAp(@turn) > 0
        return
    @_openTurnConfMenu()
    return

  _openResult: ->
    @_pushScene nz.SceneBattleResult
      mapSprite: @mapSprite
      status: @status
      data: @data
    @one 'resume', ->
      if @data.replay?
        @_startReplay()
      else
        @eventHandler.endBattleScene()
        @app.popScene()
      return
    return

  _startReplay: ->
    return unless @data.replay?
    si = @data.startInfo
    for sc,i in @characterSprites
      c    = sc.character
      o    = si.characters[i]
      c.hp = o.hp
      c.sp = o.sp
      sc.setMapPosition(o.mapx,o.mapy)
      sc.setDirection(o.direction)
      sc.applyPosition()
      sc.show()
    @_startBattlePhase(@data.replay)
    return

  _exitGame: ->
    nz.system.restart()
    return

  _startInputPhase: () ->
    @data.turn += 1
    #console.log "battle turn #{@data.turn}"
    characters = @characters.map (c) -> c.createAiInfo()
    for c,i in characters when not (@controlTeam.contains c.team) and c.isAlive()
      nz.system.ai[c.ai.name]?.setupAction new nz.ai.Param(
        character: c
        characters: characters
        graph: @mapSprite.graph
        turn: @turn
      )
      @characters[i].commands[@turn] = c.commands[@turn]
    @eventHandler.refreshStatus()

    if @controlTeam.length is 0
      @_startBattlePhase()
    else
      @popMessage(message:"Turn #{@data.turn}")
      @description MSGS.battle.phase.command

  _startBattlePhase: (param) ->
    {
      start
      end
    } = {
      start: @turn
      end: @turn
    }.$extend param
    @_pushScene(
      nz.SceneBattlePhase(
        start: start
        end: end
        mapSprite: @mapSprite
        status: @status
      )
    )
    @one 'resume', ->
      @_createResult()
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
          @one 'resume', @_addRotateCommand
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
      @_addMoveCommand()
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
          @one 'resume', @_addMoveCommand
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
