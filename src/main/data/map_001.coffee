
mapdata =
  width:  15 # マップの幅
  height: 15 # マップの高さ
  data: for y in [0 ... 15] then for x in [0 ... 15] then 1

mapdata.data[5][5] = 2
mapdata.data[5][6] = 2
mapdata.data[6][5] = 2
mapdata.data[6][6] = 2
mapdata.data[8][6] = 3

module.exports = mapdata
