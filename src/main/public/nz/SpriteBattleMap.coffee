###*
* @file SpriteBattleMap.coffee
* 戦闘マップスプライト
###

tm.define 'nz.SpriteBattleMap',
  superClass: tm.display.CanvasElement

  ###* 初期化
  * @classdesc 戦闘マップスプライト
  * @constructor nz.SpriteBattleMap
  ###
  init: (@map) ->
    @superInit()
    @chips  = []
    @blinks = []
    @width  = @map.width  * nz.system.map.chip.width
    @height = @map.height * nz.system.map.chip.height
    for mapx in [0...@map.width]
      @chips[mapx] = []
      @blinks[mapx] = []
      h = if mapx % 2 != 0 then @map.height else @map.width - 1
      for mapy in [0...h]
        @_createMapChip(mapx,mapy)
    return

  # 座標位置のマップチップを作成
  _createMapChip: (mapx,mapy) ->
    {
      width
      height
    } = nz.system.map.chip

    x = mapx * width  + width  * 0.5
    y = mapy * height + height * 0.5

    # 疑似ヘックス表示にするために奇数の座標は半分ずらす
    if mapx % 2 == 0
      y += height * 0.5

    # TODO: マップデータから座標位置のマップチップインデックスを取得する
    index = 3 # data[mapx][mapy]
    mapSprite = @

    chip = tm.display.Sprite('map_chip',width,height)
      .addChildTo(@)
      .setPosition(x,y)
      .setFrameIndex(index)
      .setInteractive(true)
      .setBoundingType('rect')
      .on 'pointingover', (e) ->
        e.mapx = mapx
        e.mapy = mapy
        mapSprite.pointingover(e) if mapSprite.pointingover?
      .on 'pointingout', (e) ->
        e.mapx = mapx
        e.mapy = mapy
        mapSprite.pointingout(e) if mapSprite.pointingout?

    blink = tm.display.RectangleShape(
      width: width
      height: width
      strokeStyle: 'white'
      fillStyle: 'white'
    )
      .addChildTo(@)
      .setPosition(x,y)
      .setInteractive(true)
      .setAlpha(0.0)
      .on 'pointingover', (e) -> @_blickOn()
      .on 'pointingout' , (e) -> @_blickOff()
    blink._blickOn  = @_blickOn
    blink._blickOff = @_blickOff

    @chips[mapx][mapy] = chip
    @blinks[mapx][mapy] = blink

  _blickOn: (blink=@) ->
    blink.tweener.clear().fade(0.5,200)
    return

  _blickOff: (blink=@) ->
    blink.tweener.clear().fadeOut(200)
    return
