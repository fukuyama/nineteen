###*
* @file SceneBattle.coffee
* 戦闘シーン
###

SCREEN_W   = nz.system.screen.width
SCREEN_H   = nz.system.screen.height
DIRECTIONS = nz.system.character.directions
ACTION_COST = nz.system.character.action_cost

tm.define 'nz.SceneBattle',
  superClass: tm.app.Scene

  ###* 初期化
  * @classdesc 戦闘シーンクラス
  * @constructor nz.SceneBattle
  ###
  init: (param) ->
    console.log 'SceneBattle'
    {
      @mapId
    } = param
    @superInit()
    @mapName = 'map_' + "#{@mapId}".paddingLeft(3,'0')
    @_selectCharacterIndex = 0

    @turn = 0 # 戦闘ターン数
    @command = null

    @on 'enter', @load.bind @

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
    # ゲームデータ
    @map = tm.asset.Manager.get(@mapName).data
    unless @map.graph?
      @map.graph = new nz.Graph
        mapdata: @map
        chipdata: tm.asset.Manager.get('chipdata').data

    characters = [
      nz.Character(name:'キャラクター１',mapx:7,mapy:14)
      nz.Character(name:'キャラクター２',mapx:7,mapy:0,direction:3)
    ]

    # TODO: 情報を表示する場所
    tm.display.Label('Information')
      .addChildTo(@)
      .setAlign('left')
      .setBaseline('top')
      .setPosition(0,0)

    # スプライト
    @mapSprite = nz.SpriteBattleMap(@map).addChildTo(@)
    @mapSprite.x += 32 * 5

    for character,i in characters
      @characterSprites.push nz.SpriteCharacter(i,character).addChildTo(@mapSprite)

    # 基本操作
    @on 'character.pointingend', (e) ->
      @_selectCharacterIndex = e.characterIndex
      @_selectGhost          = e.ghost
      @_openCharacterMenu()
    @on 'map.pointingend', (e) ->
      unless @mapSprite.findCharacter(e.mapx,e.mapy)?
        @_openMainMenu()

  _commandScene: (klass,callback) ->
    target = @selectCharacterSprite
    if @_selectGhost
      target = @selectCharacterSprite.ghost
    else
      @selectCharacter.clearAction(@turn)
    scene = klass(
      turn: @turn
      target: target
      callback: callback
      map: @map
      mapSprite: @mapSprite
    )
    @one 'pause', -> @mapSprite.addChildTo scene
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
    menuDialog = tm.ui.MenuDialog(param)
    menuDialog.on 'menuclosed', (e) -> menuFunc[e.selectIndex]?.call(null)
    menuDialog.box.setStrokeStyle nz.system.dialog.strokeStyle
    menuDialog.box.setFillStyle   nz.system.dialog.fillStyle
    return menuDialog

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
    @app.pushScene @_createMenuDialog(
      title: @selectCharacter.name
      menu: ['Move','Direction','Attack','Shot','Close Menu']
      menuFunc: [
        -> self._commandScene nz.SceneBattleMoveCommand, self._addMoveCommand.bind self
        -> self._commandScene nz.SceneBattleDirectionCommand, self._addRotateCommand.bind self
        -> self._commandScene nz.SceneBattleMoveCommand, self._addAttackCommand.bind self
        -> self._commandScene nz.SceneBattleShotCommand, self._addShotCommand.bind self
      ]
    )

  _openCommandConf: ->
    @app.pushScene @_createMenuDialog(
      title: 'Start Next Turn?'
      menu: ['Yes','No']
      menuFunc: [
        @_startTurn.bind @
      ]
    )

  _startTurn: ->
    console.log 'turn start'
    for character in @characterSprites
      character.clearGhost()
      character.startAction(@turn)
    @update = @_updateTurn
    return

  _updateTurn: ->
    endflag = false
    for character in @characterSprites
      @_updateAttack(character)
      endflag |= character.action
    @_endTurn() unless endflag

  _endTurn: ->
    @turn += 1
    @update = null
    console.log 'turn end'

  _updateAttack: (character) ->
    for target,i in @characterSprites when character.index != i
      character.updateAttack(target)

  _addMoveCommand: (route) ->
    @selectCharacter.addMoveCommand @turn, route
    if route.length > 0
      p = route[route.length-1]
      @selectCharacterSprite.createGhost(p.direction,p.mapx,p.mapy).addChildTo @mapSprite
    return

  _addAttackCommand: (route) ->
    @selectCharacter.setAttackCommand @turn
    @_addMoveCommand(route)
    return

  _addShotCommand: (rotation) ->
    @selectCharacter.addShotCommand @turn, rotation
    unless @selectCharacterSprite.ghost?
      s = @selectCharacterSprite
      s.createGhost(s.direction,s.mapx,s.mapy).addChildTo @mapSprite
    return

  _addRotateCommand: (direction1,direction2) ->
    @selectCharacter.addRotateCommand @turn, direction1, DIRECTIONS[direction1].rotateIndex[direction2]
    unless @selectCharacterSprite.ghost?
      s = @selectCharacterSprite
      s.createGhost(direction2,s.mapx,s.mapy).addChildTo @mapSprite
    else
      @selectCharacterSprite.ghost.setDirection(direction2)
    return


nz.SceneBattle.prototype.getter 'characterSprites', -> @mapSprite.characterSprites
nz.SceneBattle.prototype.getter 'selectCharacterSprite', -> @characterSprites[@_selectCharacterIndex]
nz.SceneBattle.prototype.getter 'selectCharacter', -> @selectCharacterSprite.character

tm.define 'nz.SceneBattleMoveCommand',
  superClass: tm.app.Scene

  init: (param) ->
    @superInit()
    {
      @turn
      @target
      @callback
      @map
      @mapSprite
    } = param

    @on 'map.pointingover', @_over
    @on 'map.pointingend', @_end

  searchRoute : (emapx, emapy)->
    {direction,mapx,mapy} = @target
    @map.graph.searchRoute(direction, mapx, mapy, emapx, emapy)

  commandAp: ->
    @target.character.ap - @target.character.getActionCost(@turn)

  _end: (e) ->
    @callback @searchRoute(e.mapx, e.mapy)
    @one 'enterframe', -> @app.popScene()
    return

  _over: (e) ->
    @mapSprite.clearBlink()
    ap = @commandAp()
    route = @searchRoute(e.mapx, e.mapy)
    for r in route
      if ap < r.cost
        break
      @mapSprite.blink(r.mapx,r.mapy)

tm.define 'nz.SceneBattleAttackCommand',
  superClass: nz.SceneBattleMoveCommand

  init: (param) ->
    @superInit(param)

  commandAp: ->
    @target.character.ap - @target.character.getActionCost(@turn) - ACTION_COST.attack

tm.define 'nz.SceneBattleShotCommand',
  superClass: tm.app.Scene

  init: (param) ->
    @superInit()
    {
      @turn
      @target
      @callback
      @map
    } = param

    @on 'map.pointingstart', @_pointStart
    @on 'pointingmove', @_pointMove
    @on 'map.pointingend', @_pointEnd

  _pointStart: (e) ->
    @_removePointer()
    @_createPointer()
    @_movePointer(e.pointing)
    return

  _pointMove: (e) ->
    @_movePointer(e.pointing)
    return

  _pointEnd: (e) ->
    @_setupCommand()
    @_removePointer()
    @_endScene()
    return

  _setupCommand: ->
    if @pointer?
      @callback(@pointer.rotation)
    return

  _endScene: ->
    @one 'enterframe', -> @app.popScene()
    return

  _createPointer: ->
    @pointer = tm.display.Shape(
      width: 40
      height: 10
    ).addChildTo @target
      .setOrigin(0.0,0.5)
    tm.display.CircleShape(
      x: 40
      width: 10
      height: 10
      fillStyle: 'blue'
    ).addChildTo @pointer
    return

  _removePointer: ->
    if @pointer?
      @pointer.remove()
      @pointer = null
    return

  _movePointer: (pointing) ->
    if @pointer?
      t = @target.body.localToGlobal tm.geom.Vector2(0,0)
      x = pointing.x - t.x
      y = pointing.y - t.y
      v = tm.geom.Vector2 x,y
      r = Math.radToDeg v.toAngle()
      @pointer.rotation = r
    return

tm.define 'nz.SceneBattleDirectionCommand',
  superClass: nz.SceneBattleShotCommand

  init: (param) ->
    @superInit(param)

    @_direction = null

  _setupCommand: ->
    if @_direction?
      @callback(@target.direction,@_direction)
    return

  _movePointer: (pointing) ->
    return unless @pointer?
    t = @target.body.localToGlobal tm.geom.Vector2(0,0)
    x = pointing.x - t.x
    y = pointing.y - t.y
    v = tm.geom.Vector2 x,y
    rotation = Math.radToDeg v.toAngle()
    for d,i in DIRECTIONS when 0 <= i and i < 6
      if d.rotation - 30 < rotation and rotation < d.rotation + 30
        if @_direction != d.index
          @_direction = d.index
          @pointer.rotation = d.rotation
          return
    return
