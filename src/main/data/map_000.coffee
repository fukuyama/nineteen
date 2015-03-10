
MAP_WIDTH  = 13 # マップの幅
MAP_HEIGHT = 13 # マップの高さ

mapdata =
  width:  MAP_WIDTH
  height: MAP_HEIGHT
  data: for y in [0 ... MAP_HEIGHT] then for x in [0 ... MAP_WIDTH] then 0

module.exports = mapdata
