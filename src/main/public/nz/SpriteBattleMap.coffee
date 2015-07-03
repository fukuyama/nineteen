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
      h = if mapx % 2 != 0 then @map.height else @map.height - 1
      for mapy in [0...h]
        @_initMapChip(mapx,mapy)

    @cursor = @_createCursor().addChildTo(@)
    @setCursorPosition @getMapChip(0,0)

    @on 'startBattlePhase', (e) ->
      @cursor.visible = false
      return
    @on 'endBattlePhase', (e) ->
      @cursor.visible = true
      return

    @on 'input_up'     , @cursorUp
    @on 'input_down'   , @cursorDown
    @on 'input_left'   , @cursorLeft
    @on 'input_right'  , @cursorRight
    @on 'repeat_up'    , @cursorUp
    @on 'repeat_down'  , @cursorDown
    @on 'repeat_left'  , @cursorLeft
    @on 'repeat_right' , @cursorRight

    return

  setCursorPosition: (param) ->
    return unless param?
    @cursor.mapx = param.mapx if param.mapx?
    @cursor.mapy = param.mapy if param.mapy?
    @cursor.x = param.x
    @cursor.y = param.y
    return

  cursorUp: ->
    {mapx,mapy} = @cursor
    @setCursorPosition @getMapChip(mapx,mapy - 1)
    return
  cursorDown: ->
    {mapx,mapy} = @cursor
    @setCursorPosition @getMapChip(mapx,mapy + 1)
    return
  cursorLeft: ->
    {mapx,mapy} = @cursor
    chip = @getMapChip(mapx - 1,mapy)
    unless chip?
      chip = @getMapChip(mapx - 1,mapy - 1)
    @setCursorPosition chip
    return
  cursorRight: ->
    {mapx,mapy} = @cursor
    chip = @getMapChip(mapx + 1,mapy)
    unless chip?
      chip = @getMapChip(mapx + 1,mapy - 1)
    @setCursorPosition chip
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
    cursor = tm.display.Shape(
      x:           0
      y:           0
      width:       MAP_CHIP_W
      height:      MAP_CHIP_H
      strokeStyle: 'red'
      lineWidth:   3
      visible:     true
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
    {
      x
      y
    } = nz.utils.mapxy2screenxy(mapx,mapy)

    # マップデータから座標位置のマップチップを取得する
    node = @graph.grid[mapx][mapy]
    frameIndex = node.frame

    # TODO: マップごとに画像を変更したい
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

    chip.on 'pointingover', @setCursorPosition.bind @, chip

    tm.display.Label("#{mapx},#{mapy}",{fontSize:8}).setPosition(0,h/2-8).addChildTo(chip)

    if node.object?
      tm.display.Sprite('map_object',w,h*2)
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
