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
        @_initMapChip(mapx,mapy)

    @cursor = @_createCursor().addChildTo(@)

    for line in @_chips
      for chip in line
        chip.on 'pointingover', ->
          @parent.cursor.x = @x
          @parent.cursor.y = @y

    #@setInteractive(true)
    #@on 'pointingover', -> @cursor.show()
    #@on 'pointingout', -> @cursor.hide()

    return

  _createCursor: ->
    cursor = tm.display.Shape(
      width: nz.system.map.chip.width
      height: nz.system.map.chip.height
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
    {
      width
      height
    } = nz.system.map.chip

    x = mapx * width  + width  * 0.5
    y = mapy * height + height * 0.5

    # 疑似ヘックス表示にするために偶数の座標は半分ずらす
    y += height * 0.5 if mapx % 2 == 0

    # マップデータから座標位置のマップチップを取得する
    node = @map.graph.grid[mapx][mapy]
    frameIndex = node.frame

    chip = tm.display.Sprite('map_chip',width,height)
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
      width: width
      height: width
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
