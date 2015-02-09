###*
* @file SceneBattle.coffee
* 戦闘シーン
###

debugdata =
  mapdata:
    width:  15 # マップの幅
    height: 15 # マップの高さ
    data: for y in [0 ... 15] then for x in [0 ... 15] then 1

debugdata.mapdata.data[5][5] = 2
debugdata.mapdata.data[5][6] = 2
debugdata.mapdata.data[6][5] = 2
debugdata.mapdata.data[6][6] = 2
debugdata.mapdata.data[8][6] = 3

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
    @mapName = 'map_001'

  setup: () ->
    @map = tm.asset.Manager.get(@mapName).data
    chipdata = tm.asset.Manager.get('chipdata').data

    @characters = [
      {
        name: 'テストキャラクター'
        spriteSheet: 'character_001'
        mapx: 10
        mapy: 10
        direction: 1
      }
    ]

    @map.graph = new nz.Graph(mapdata:@map,chipdata:chipdata)
    @mapSprite = nz.SpriteBattleMap(@map).addChildTo(@)
    @mapSprite.x += 32 * 5

    @characterSprites = for character in @characters
      nz.SpriteCharacter(character)
        .addChildTo(@mapSprite)
        .on 'pointingend', (e) ->
          e.app.currentScene._openCharacterMenu(@character)

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

  _openCharacterMenu: (character)->
    @selectCharacter = character
    @app.pushScene tm.ui.MenuDialog(
      screenWidth: nz.system.screen.width
      screenHeight: nz.system.screen.height
      title: character.name
      showExit: true
      menu: ['移動','攻撃','射撃']
    ).on('menuselected', @_characterMenuSelected.bind(@))

  _characterMenuSelected: (e) ->
    if e.selectIndex == 0 # 移動
      @mapSprite.pointingover = ((e) ->
        @searchRoute(@selectCharacter,e.mapx,e.mapy)
      ).bind @
      @one 'pointingend', (e) ->
        @mapSprite.pointingover = null

  searchRoute: (character,mapx,mapy) ->
    start = @map.graph.grid[character.mapx][character.mapy]
    start.direction = character.direction
    end = @map.graph.grid[mapx][mapy]
    result = astar.search(@map.graph, start, end, {heuristic: nz.Graph.heuristic})
    @mapSprite.clearBlink()
    for node in result
      @mapSprite.blink(node.x,node.y)
