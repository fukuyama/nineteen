
mapdata =
  width:  15 # マップの幅
  height: 15 # マップの高さ
  data: for y in [0 ... 15] then for x in [0 ... 15] then 1

x = Math.floor(Math.random() * 10 + 3)
y = Math.floor(Math.random() * 10 + 3)
mapdata.data[x  ][y  ] = 2
mapdata.data[x  ][y+1] = 2
mapdata.data[x+1][y+1] = 2
mapdata.data[x+1][y  ] = 2

for i in [0 ... 15]
  x = Math.floor(Math.random() * 15)
  y = Math.floor(Math.random() * 15)
  mapdata.data[x][y] = 3

module.exports = mapdata
