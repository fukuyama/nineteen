###*
* @file SceneBattle.coffee
* 戦闘シーン
###

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
    @selectCharacterIndex = 0

    @turn = 0 # 戦闘ターン数
    @command = null

    @on 'enter', @load.bind @

  load: () ->
    assets = {}
    assets[@mapName] = "data/#{@mapName}.json"

    scene = tm.scene.LoadingScene(
      assets: assets
      width: nz.system.screen.width
      height: nz.system.screen.height
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
      nz.Character(name:'キャラクター２',mapx:7,mapy:0,direction:4)
    ]

    #
    tm.display.Label('Information')
      .addChildTo(@)
      .setAlign('left')
      .setBaseline('top')
      .setPosition(0,0)

    # スプライト
    @mapSprite = nz.SpriteBattleMap(@map).addChildTo(@)
    @mapSprite.x += 32 * 5

    @characterSprites = for character,i in characters
      nz.SpriteCharacter(i,character).addChildTo(@mapSprite)

    # 基本操作
    @on 'character.pointingend', (e) ->
      @selectCharacterIndex = e.characterIndex
      @_openCharacterMenu()
    @on 'map.pointingend', (e) ->
      unless @findCharacter(e.mapx,e.mapy)?
        @_openMainMenu()

  # 指定された座標のキャラクターを探す
  findCharacter: (mapx,mapy) ->
    for sprite in @characterSprites
      if sprite.character.mapx == mapx and sprite.character.mapy == mapy
        return sprite
    return null

  _createMenuDialog: (_param) ->
    param = {
      screenWidth: nz.system.screen.width
      screenHeight: nz.system.screen.height
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
      menu: ['ターンエンド','オプション','ゲームエンド','閉じる']
      menuFunc: [
        @_menuTurnEnd.bind @
        -> return
        (e) -> e.app.replaceScene nz.SceneTitleMenu()
      ]
    )

  _openCharacterMenu: ->
    self = @
    @app.pushScene @_createMenuDialog(
      title: @selectCharacter.name
      menu: ['移動','攻撃','射撃','リセット','閉じる']
      menuFunc: [
        -> self._commandScene nz.SceneBattleMoveCommand
        -> self._commandScene nz.SceneBattleAttackCommand
        -> self._commandScene nz.SceneBattleShotCommand
        -> self.selectCharacter.clearAction()
      ]
    )

  _menuTurnEnd: ->
    @app.pushScene @_createMenuDialog(
      title: 'ターンエンド？'
      menu: ['Yes','No']
      menuFunc: [
        @_turnEnd.bind @
      ]
    )

  _turnEnd: ->
    for character in @characterSprites
      character.startAction(@turn)
    @turn += 1
    return

  _commandScene: (klass) ->
    scene = klass(
      turn: @turn
      target: @selectCharacterSprite
      map: @map
      mapSprite: @mapSprite
    )
    @one 'pause', -> @mapSprite.addChildTo scene
    @one 'resume', -> @mapSprite.addChildTo @
    @app.pushScene scene
    return

nz.SceneBattle.prototype.getter 'selectCharacterSprite', -> @characterSprites[@selectCharacterIndex]
nz.SceneBattle.prototype.getter 'selectCharacter', -> @characterSprites[@selectCharacterIndex].character





tm.define 'nz.SceneBattleMoveCommand',
  superClass: tm.app.Scene

  init: (param) ->
    @superInit()
    {
      @turn
      @target
      @map
      @mapSprite
    } = param

    @on 'map.pointingend', @_pointEnd

  _pointEnd: (e) ->
    {direction,mapx,mapy} = @target.character
    route = @map.graph.searchRoute(direction, mapx, mapy, e.mapx, e.mapy)
    @target.character.addRoute @turn, route
    if route.length > 0
      @target.createGhost(route[route.length-1].direction,e.mapx,e.mapy).addChildTo @mapSprite
    @app.popScene()
    return

tm.define 'nz.SceneBattleAttackCommand',
  superClass: tm.app.Scene

  init: (param) ->
    @superInit()
    {
      @turn
      @target
      @map
    } = param

    @on 'map.pointingend', @_pointEnd

  _pointEnd: (e) ->
    {direction,mapx,mapy} = @target.character
    route = @map.graph.searchRoute(direction, mapx, mapy, e.mapx, e.mapy)
    @target.character.setAttack @turn
    @target.character.addRoute @turn, route
    @app.popScene()
    return

tm.define 'nz.SceneBattleShotCommand',
  superClass: tm.app.Scene

  init: (param) ->
    @superInit()
    {
      @turn
      @target
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
      @target.character.addShot @turn, @pointer.rotation
    return

  _endScene: ->
    @app.popScene()
    return

  _createPointer: ->
    @pointer = tm.display.Shape(
      width: 50
      height: 10
    ).addChildTo @target
      .setOrigin(0.0,0.5)
    tm.display.CircleShape(
      x: 50
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
