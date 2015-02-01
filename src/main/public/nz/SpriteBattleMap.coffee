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
    for mapx in [0...@map.width]
      for mapy in [0...@map.height]
        @_createMapChip(mapx,mapy)

    return

  # 座標位置のマップチップを作成
  _createMapChip: (mapx,mapy) ->
    {
      width
      height
    } = nz.system.map.chip

    x = mapx * width + width * 0.5
    y = mapy * height + height * 0.5

    # 疑似ヘックス表示にするために奇数の座標は半分ずらす
    if mapx % 2 == 0
      y += height * 0.5
      # ずらした場合、最後の表示列の場合１つ減らす
      if mapy == @map.height - 1
        return

    # TODO: マップデータから座標位置のマップチップインデックスを取得する
    index = 0 # data[x][y]

    tm.display.Sprite('map_chip',width,height)
      .setPosition(x,y)
      .setFrameIndex(index)
      .addChildTo(@)

