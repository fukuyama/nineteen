###*
* @file SceneBattle.coffee
* 戦闘シーン
###

debugdata =
  chipdata: [
    {
      weight: 0
    }
    {
      weight: 1
    }
  ]
  mapdata:
    width:  15 # マップの幅
    height: 15 # マップの高さ
    data: for y in [0 ... 15] then for x in [0 ... 15] then 1

tm.define 'nz.SceneBattle',
  superClass: tm.app.Scene

  ###* 初期化
  * @classdesc 戦闘シーンクラス
  * @constructor nz.SceneBattle
  ###
  init: () ->
    console.log 'SceneBattle'
    @superInit()

    @map = debugdata.mapdata

    @characters = [
      {
        name: 'テストキャラクター'
        spriteSheet: 'character_001'
        mapx: 10
        mapy: 10
        direction: 1
      }
    ]

    @_graph = new nz.Graph(mapdata:@map,chipdata:debugdata.chipdata)
    @mapSprite = nz.SpriteBattleMap(@map).addChildTo(@)
    @mapSprite.x += 32 * 5

    @characterSprites = for character in @characters
      nz.SpriteCharacter(character)
        .addChildTo(@mapSprite)
        .on 'pointingend', (e) ->
          e.app.currentScene._openCharacterMenu(@character)

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
    start = @_graph.grid[character.mapx][character.mapy]
    end = @_graph.grid[mapx][mapy]
    result = astar.search(@_graph, start, end, {heuristic: nz.Graph.heuristic})
    @mapSprite.clearBlink()
    for node in result
      @mapSprite.blink(node.x,node.y)

