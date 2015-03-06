###*
* @file SpriteBattleMap.coffee
* 戦闘マップスプライト
###

MAP_CHIP_W = nz.system.map.chip.width
MAP_CHIP_H = nz.system.map.chip.height

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
    @characterSprites = []

    @width  = @map.width  * MAP_CHIP_W
    @height = @map.height * MAP_CHIP_H
    for mapx in [0...@map.width]
      h = if mapx % 2 != 0 then @map.height else @map.width - 1
      for mapy in [0...h]
        @_initMapChip(mapx,mapy)

    @cursor = @_createCursor().addChildTo(@)

    for line in @_chips
      for chip in line
        chip.on 'pointingover', ->
          @parent.cursor.x = @x
          @parent.cursor.y = @y

    return

  # 指定された座標のキャラクターを探す
  findCharacter: (mapx,mapy) ->
    for character in @characterSprites
      if character.mapx == mapx and character.mapy == mapy
        return character
      if character.ghost?.mapx == mapx and character.ghost?.mapy == mapy
        return character
    return null

  _createCursor: ->
    cursor = tm.display.Shape(
      width: MAP_CHIP_W
      height: MAP_CHIP_H
      strokeStyle: 'red'
      lineWidth: 3
    )
    cursor._render = -> @canvas.strokeRect(0, 0, @width, @height)
    cursor.render()
    return cursor

  # MapChip用イベントハンドラ
  _dispatchMapChipEvent: (_e) ->
    e = tm.event.Event('map.' + _e.type)
    e.app = _e.app
    e.pointing = _e.pointing
    e.mapx = @mapx
    e.mapy = @mapy
    e.app.currentScene.dispatchEvent e
    return

  # 座標位置のマップチップを作成
  _initMapChip: (mapx,mapy) ->
    w = MAP_CHIP_W
    h = MAP_CHIP_H
    x = mapx * w + w * 0.5
    y = mapy * h + h * 0.5

    # 疑似ヘックス表示にするために偶数の座標は半分ずらす
    y += h * 0.5 if mapx % 2 == 0

    # マップデータから座標位置のマップチップを取得する
    node = @map.graph.grid[mapx][mapy]
    frameIndex = node.frame

    chip = tm.display.Sprite('map_chip',w,h)
      .addChildTo(@)
      .setPosition(x,y)
      .setFrameIndex(frameIndex)
      .setInteractive(true)
      .setBoundingType('rect')
      .on 'pointingstart', @_dispatchMapChipEvent
      .on 'pointingover', @_dispatchMapChipEvent
      .on 'pointingout', @_dispatchMapChipEvent
      .on 'pointingend', @_dispatchMapChipEvent
    chip.mapx = mapx
    chip.mapy = mapy

    if node.object?
      tm.display.Sprite('map_object',32,64)
        .setOrigin(0.5,0.75)
        .addChildTo(chip)
        .setFrameIndex(node.object.frame)

    blink = tm.display.RectangleShape(
      width: w
      height: h
      strokeStyle: 'white'
      fillStyle: 'white'
    ).addChildTo(@)
      .setPosition(x,y)
      .setInteractive(true)
      .setAlpha(0.0)

    @_chips[mapx] = [] unless @_chips[mapx]?
    @_chips[mapx][mapy] = chip
    @_blinks[mapx] = [] unless @_blinks[mapx]?
    @_blinks[mapx][mapy] = blink
    return

  blink: (mapx,mapy) ->
    blink = @_blinks[mapx][mapy]
    if blink?
      blink.setAlpha(0.5)
      @_clearblinks.push blink
    return

  clearBlink: () ->
    for blink in @_clearblinks
      blink.setAlpha(0.0)
    @_clearblinks.clear()
    return

  getMapChip: (mapx,mapy) -> @_chips[mapx][mapy]
