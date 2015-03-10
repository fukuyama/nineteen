
MAP_WIDTH  = 13 # マップの幅
MAP_HEIGHT = 13 # マップの高さ

mapdata =
  width:  MAP_WIDTH
  height: MAP_HEIGHT
  data: for y in [0 ... MAP_HEIGHT] then for x in [0 ... MAP_WIDTH] then 1

x = Math.floor(Math.random() * 8 + 3)
y = Math.floor(Math.random() * 8 + 3)
mapdata.data[x  ][y  ] = 2
mapdata.data[x  ][y+1] = 2
mapdata.data[x+1][y+1] = 2
mapdata.data[x+1][y  ] = 2

for i in [0 ... MAP_WIDTH]
  x = Math.floor(Math.random() * (MAP_WIDTH  - 4) + 2)
  y = Math.floor(Math.random() * (MAP_HEIGHT - 4) + 2)
  mapdata.data[x][y] = 3

for i in [0 ... 4]
  x = Math.floor(Math.random() * (MAP_WIDTH  - 4) + 2)
  y = Math.floor(Math.random() * (MAP_HEIGHT - 4) + 2)
  mapdata.data[x][y] = 4

module.exports = mapdata
