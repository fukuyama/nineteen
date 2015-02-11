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

    @characterSprites = for character,i in @characters
      nz.SpriteCharacter(i,character)
        .addChildTo(@mapSprite)
        .on 'pointingend', (e) ->
          e.app.currentScene._openCharacterMenu(@num)

  _openCharacterMenu: (num)->
    @selectCharacterIndex = num
    @app.pushScene tm.ui.MenuDialog(
      screenWidth: nz.system.screen.width
      screenHeight: nz.system.screen.height
      title: @characters[@selectCharacterIndex].name
      showExit: true
      menu: ['移動','攻撃','射撃']
    ).on('menuselected', @_characterMenuSelected.bind(@))

  _characterMenuSelected: (e) ->
    if e.selectIndex == 0 # 移動
      @mapSprite.pointingend = @_menuMoveCommand.bind @
    if e.selectIndex == 1 # 攻撃
      @characterSprites[@selectCharacterIndex].gotoAndPlay('down')


  _menuMoveCommand: (e) ->
    route = @searchRoute(@selectCharacterIndex,e.mapx,e.mapy)
    @characterSprites[@selectCharacterIndex].mapMove route
    @mapSprite.pointingend = null

  searchRoute: (character,mapx,mapy) ->
    if typeof character is 'number'
      character = @characters[character]
    @map.graph.init()
    start = @map.graph.grid[character.mapx][character.mapy]
    start.direction = character.direction
    end = @map.graph.grid[mapx][mapy]
    return astar.search(@map.graph, start, end, {heuristic: nz.Graph.heuristic})
