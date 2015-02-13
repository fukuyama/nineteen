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

    @on 'enter', @load.bind @

  load: () ->
    console.log "battle map load #{@mapName}"
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

    @characters = [
      nz.Character(name:'キャラクター１',mapx:7,mapy:14)
      nz.Character(name:'キャラクター２',mapx:7,mapy:0,direction:4)
    ]

    # スプライト
    @mapSprite = nz.SpriteBattleMap(@map).addChildTo(@)
    @mapSprite.x += 32 * 5

    @characterSprites = for character,i in @characters
      nz.SpriteCharacter(i,character).addChildTo(@mapSprite)

    # イベント
    @on 'character.pointingend', @_openCharacterMenu

  _openCharacterMenu: (e)->
    @selectCharacterIndex = e.characterIndex
    menuFunc = [
      @_menuMoveCommandStart.bind @
      @_menuAttackCommandStart.bind @
      @_menuShootingCommandStart.bind @
    ]
    @app.pushScene tm.ui.MenuDialog(
      screenWidth: nz.system.screen.width
      screenHeight: nz.system.screen.height
      title: @characters[@selectCharacterIndex].name
      showExit: true
      menu: ['移動','攻撃','射撃']
    ).on 'menuselected', (e) -> menuFunc[e.selectIndex]?.call(null)

  # 移動コマンド操作開始
  _menuMoveCommandStart: ->
    @one 'map.pointingend', @_menuMoveCommandEnd

  # 移動コマンド操作終了
  _menuMoveCommandEnd: (e) ->
    character = @characterSprites[@selectCharacterIndex]
    character.mapMove @searchRoute(character.character, e.mapx, e.mapy)

  # 射撃コマンド操作開始
  _menuShootingCommandStart: ->

  # 射撃コマンド操作終了
  _menuShootingCommandEnd: ->

  # 攻撃コマンド操作開始
  _menuAttackCommandStart: ->
    character = @characterSprites[@selectCharacterIndex]
    character.attackAnimationStart()

  # 攻撃コマンド操作終了
  _menuAttackCommandEnd: ->

  searchRoute: (character,mapx,mapy) ->
    if typeof character is 'number'
      character = @characters[character]
    graph = @map.graph
    start = graph.grid[character.mapx][character.mapy]
    end   = graph.grid[mapx][mapy]

    start.direction = character.direction
    result = astar.search(graph, start, end, {heuristic: nz.Graph.heuristic})
    route = []
    for node in result
      route.push {
        x: node.x
        y: node.y
        direction: node.direction
      }
    graph.clear()
    return route
