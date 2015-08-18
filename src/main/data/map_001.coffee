
MAP_WIDTH  = 13 # マップの幅
MAP_HEIGHT = 13 # マップの高さ
CENTER     = 6

mapdata =
  width:  MAP_WIDTH
  height: MAP_HEIGHT
  start:
    area: [
      [[CENTER,     11], [CENTER / 2,         12], [CENTER + CENTER / 2,                  12]]
      [[CENTER,      0], [CENTER / 2,          0], [CENTER + CENTER / 2,                   0]]
      [[     0, CENTER], [         0, CENTER / 2], [                  0, CENTER + CENTER / 2]]
      [[    12, CENTER], [        12, CENTER / 2], [                 12, CENTER + CENTER / 2]]
    ]
  data: for y in [0 ... MAP_HEIGHT] then for x in [0 ... MAP_WIDTH] then 1

area_check = (x,y) ->
  for area in mapdata.start.area
    for pos in area
      if pos[0] is x and pos[1] is y
        return false
  return true

x = Math.floor(Math.random() * 7 + 3)
y = Math.floor(Math.random() * 7 + 3)
mapdata.data[x  ][y  ] = 2
mapdata.data[x  ][y+1] = 2
mapdata.data[x+1][y+1] = 2
mapdata.data[x+1][y  ] = 2

for i in [0 ... MAP_WIDTH]
  x = Math.floor(Math.random() * MAP_WIDTH )
  y = Math.floor(Math.random() * MAP_HEIGHT)
  mapdata.data[x][y] = 3 if area_check x,y

for i in [0 ... 4]
  x = Math.floor(Math.random() * MAP_WIDTH )
  y = Math.floor(Math.random() * MAP_HEIGHT)
  mapdata.data[x][y] = 4 if area_check x,y

module.exports = mapdata
