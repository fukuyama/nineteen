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
    @_chips  = []
    @_blinks = []
    @_clearblinks = []
    @width  = @map.width  * nz.system.map.chip.width
    @height = @map.height * nz.system.map.chip.height
    for mapx in [0...@map.width]
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
    node = @map.graph.grid[mapx][mapy]
    frameIndex = node.frame
    mapSprite = @

    chip = tm.display.Sprite('map_chip',width,height)
      .addChildTo(@)
      .setPosition(x,y)
      .setFrameIndex(frameIndex)
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
      .on 'pointingend', (e) ->
        e.mapx = mapx
        e.mapy = mapy
        mapSprite.pointingend(e) if mapSprite.pointingend?

    if node.object?
      tm.display.Sprite('map_object',32,64)
        .setOrigin(0.5,0.75)
        .addChildTo(chip)
        .setFrameIndex(node.object.frame)

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

    @_chips[mapx] = [] unless @_chips[mapx]?
    @_chips[mapx][mapy] = chip
    @_blinks[mapx] = [] unless @_blinks[mapx]?
    @_blinks[mapx][mapy] = blink

  blink: (mapx,mapy) ->
    blink = @_blinks[mapx][mapy]
    if blink?
      blink.tweener.clear().fade(0.5,200)
      @_clearblinks.push blink
    return

  clearBlink: () ->
    #for blink in @_clearblinks
      #blink.tweener.clear().fadeOut(200)
    for blinks in @_blinks
      for blink in blinks
        blink.tweener.clear()
        blink.setAlpha(0.0)
    @_clearblinks.clear()
    return
