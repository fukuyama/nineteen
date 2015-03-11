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
  init: (mapName) ->
    @superInit()
    @_chips  = []
    @_blinks = []
    @_activeBlinks = []
    @characterSprites = []

    @map = tm.asset.Manager.get(mapName).data

    @graph = new nz.Graph
      mapdata: @map
      chipdata: tm.asset.Manager.get('chipdata').data

    @width  = @map.width  * MAP_CHIP_W
    @height = @map.height * MAP_CHIP_H
    for mapx in [0...@map.width]
      h = if mapx % 2 != 0 then @map.height else @map.width - 1
      for mapy in [0...h]
        @_initMapChip(mapx,mapy)

    @cursor = @_createCursor().addChildTo(@)

    self = @
    for line in @_chips
      for chip in line
        chip.on 'pointingover', ->
          self.cursor.x = @x
          self.cursor.y = @y

    @on 'battleSceneStart', (e) ->
      @cursor.visible = false
      @_dispatchBattleEvent(e)
      return
    @on 'battleSceneEnd', (e) ->
      @_dispatchBattleEvent(e)
      @cursor.visible = true
    @on 'battleTurnStart', (e) ->
      @_dispatchBattleEvent(e)
      return
    @on 'battleTurnEnd', (e) ->
      @_dispatchBattleEvent(e)
      return

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

  # 戦闘用イベントハンドラ
  _dispatchBattleEvent: (e) ->
    c.fire(e) for c in @characterSprites

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
    node = @graph.grid[mapx][mapy]
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
      .setVisible(false)

    @_chips[mapx] = [] unless @_chips[mapx]?
    @_chips[mapx][mapy] = chip
    @_blinks[mapx] = [] unless @_blinks[mapx]?
    @_blinks[mapx][mapy] = blink
    return

  blink: (mapx,mapy) ->
    blink = @_blinks[mapx][mapy]
    if blink?
      blink.visible = true
      blink.tweener.clear().fade(0.5,300).fade(0.1,300).setLoop(true)
      @_activeBlinks.push blink
    return

  clearBlink: ->
    for blink in @_activeBlinks
      blink.visible = false
      blink.setAlpha(0.0)
      blink.tweener.clear()
    @_activeBlinks.clear()
    return

  isBlink: (mapx,mapy) -> @_blinks[mapx][mapy].visible

  getMapChip: (mapx,mapy) -> @_chips[mapx][mapy]
