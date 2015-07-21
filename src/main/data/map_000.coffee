# Debug 用

MAP_WIDTH  = 13 # マップの幅
MAP_HEIGHT = 13 # マップの高さ
CENTER     = 6

mapdata =
  width:  MAP_WIDTH
  height: MAP_HEIGHT
  start:
    area: [
      [[CENTER,         11], [CENTER / 2,     12], [CENTER + CENTER / 2,                  12]]
      [[CENTER,          0], [CENTER / 2,      0], [CENTER + CENTER / 2,                   0]]
      [[     0, CENTER / 2], [         0, CENTER], [                  0, CENTER + CENTER / 2]]
      [[    12, CENTER / 2], [        12, CENTER], [                 12, CENTER + CENTER / 2]]
    ]
  data: for y in [0 ... MAP_HEIGHT] then for x in [0 ... MAP_WIDTH] then 0

module.exports = mapdata


# mapdata.data マップデータ
# ２次元配列は、データを見た時に見やすいように、data[y][x] とする。（内部で管理するときは変換されて、graph.grid[x][y]となる）
# 疑似ヘックスにするために、Y軸のデータは、Xが偶数の場合に、１つ減る。（使われない）
# ex)
# mapdata.data = [
#   [1,1,1,0,0]
#   [1,0,1,0,0]
#   [1,1,1,0,0]
#   [0,0,0,0,0]
# ]

# mapdata.start.area 戦闘開始位置の座標
# [
#   [[ 0, 0],[ 0, 1],[ 0, 2]] <-- 陣営毎に配置できる座標のグループを配列で指定（最低３か所） [x,y]
#   [[10, 0],[10, 1],[10, 2],[10, 3]]
# ]
