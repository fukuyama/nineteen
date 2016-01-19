###*
* @file SpriteBattleMap.coffee
* 戦闘マップスプライト
###

MAP_CHIP_W = nz.system.map.chip.width
MAP_CHIP_H = nz.system.map.chip.height

phina.define 'nz.SpriteBattleMap',
  superClass: phina.display.CanvasElement

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

    @map = phina.asset.AssetManager.get('json',mapName).data

    @graph = new nz.Graph
      mapdata: @map
      chipdata: phina.asset.AssetManager.get('json','chipdata').data

    @width  = @map.width  * MAP_CHIP_W
    @height = @map.height * MAP_CHIP_H
    for mapx in [0...@map.width]
      h = if mapx % 2 != 0 then @map.height else @map.height - 1
      for mapy in [0...h]
        @_initMapChip(mapx,mapy)

    @setCursorPosition @getMapChip(0,0)

    return

  # 指定された座標のキャラクターを探す
  findCharacter: (mapx,mapy) ->
    res = []
    for character in @characterSprites
      if character.mapx == mapx and character.mapy == mapy
        res.push character
    return res
  findCharacterGhost: (mapx,mapy) ->
    res = []
    for character in @characterSprites
      if character.ghost?.mapx == mapx and character.ghost?.mapy == mapy
        res.push character.ghost
    return res

  _createCursor: ->
    phina.display.RectangleShape
      width:        MAP_CHIP_W
      height:       MAP_CHIP_H
      stroke:       'red'
      strokeWidth:  3
      visible:      true
      cornerRadius: 5
      fill:         null
      backgroundColor: 'transparent'

  # MapChip用イベントハンドラ
  _dispatchMapChipEvent: (_e) ->
    e = phina.event.Event('map.' + _e.type)
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
    {
      x
      y
    } = nz.utils.mapxy2screenxy(mapx,mapy)

    # マップデータから座標位置のマップチップを取得する
    node = @graph.grid[mapx][mapy]
    frameIndex = node.frame

    # TODO: マップごとに画像を変更したい
    chip = phina.display.Sprite('map_chip',w,h)
      .addChildTo(@)
      .setPosition(x,y)
      .setFrameIndex(frameIndex,w,h)
      .setInteractive(true)
      .setBoundingType('rect')
      .on 'pointingstart', @_dispatchMapChipEvent
      .on 'pointingover', @_dispatchMapChipEvent
      .on 'pointingout', @_dispatchMapChipEvent
      .on 'pointingend', @_dispatchMapChipEvent
    chip.mapx = mapx
    chip.mapy = mapy

    chip.on 'pointingover', @setCursorPosition.bind @, chip

    # DEBUG:
    #phina.display.Label("#{mapx},#{mapy}",{fontSize:8}).setPosition(0,h/2-8).addChildTo(chip)

    if node.object?
      phina.display.Sprite('map_object',w,h*2)
        .setOrigin(0.5,0.75)
        .addChildTo(chip)
        .setFrameIndex(node.object.frame)

    blink = phina.display.RectangleShape(
      width: w
      height: h
      strokeStyle: 'white'
      fillStyle: 'white'
    ).addChildTo(@)
      .setPosition(x,y)
      .setInteractive(true)
      .setVisible(false)
    #  .setAlpha(0.0)

    @_chips[mapx] = [] unless @_chips[mapx]?
    @_chips[mapx][mapy] = chip
    @_blinks[mapx] = [] unless @_blinks[mapx]?
    @_blinks[mapx][mapy] = blink
    return

  blink: (mapx,mapy) ->
    blink = @_blinks[mapx]?[mapy]
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

  isBlink: (mapx,mapy) -> @_blinks[mapx]?[mapy]?.visible

  getMapChip: (mapx,mapy) -> @_chips[mapx]?[mapy]
