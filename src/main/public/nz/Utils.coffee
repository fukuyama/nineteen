# Utils.coffee

# node.js と ブラウザでの this.nz を同じインスタンスにする
_g = window ? global
nz = _g.nz = _g.nz ? {}
_g = undefined

MAP_CHIP_W = nz.system.map.chip.width
MAP_CHIP_H = nz.system.map.chip.height
DIRECTIONS = nz.system.character.directions

class nz.Utils

  direction: (c1,c2) ->
    dis = @distance c1,c2
    r   = Math.floor(dis / 2)
    dir = 0
    if (c2.mapx - r) <= c1.mapx and c1.mapx <= (c2.mapx + r)
      dir = 0 if c1.mapy > c2.mapy
      dir = 3 if c1.mapy < c2.mapy
    else if c1.mapx > c2.mapx # 左側
      if c1.mapy == c2.mapy
        dir = if c1.mapx % 2 == 0 then 5 else 4
      else if c1.mapy > c2.mapy
        dir = 5
      else if c1.mapy < c2.mapy
        dir = 4
    else if c1.mapx < c2.mapx # 右側
      if c1.mapy == c2.mapy
        dir = if c1.mapx % 2 == 0 then 1 else 2
      else if c1.mapy > c2.mapy
        dir = 1
      else if c1.mapy < c2.mapy
        dir = 2
    return dir

  distance: (c1,c2) ->
    hx = Math.abs(c1.mapx - c2.mapx)
    hy = Math.abs(c1.mapy - c2.mapy)
    hr = Math.ceil(hx / 2)
    return hx if hy < hr
    if hx % 2 == 1
      if c1.mapx % 2 == 1
        if c1.mapy <= c2.mapy
          hy += 1
      else
        if c1.mapy >= c2.mapy
          hy += 1
    return hx + hy - hr

  mapxy2screenxy: (p) ->
    if arguments.length == 2
      p = {
        mapx: arguments[0]
        mapy: arguments[1]
      }
    r = {
      x: p.mapx * MAP_CHIP_W + MAP_CHIP_W * 0.5
      y: p.mapy * MAP_CHIP_H + MAP_CHIP_H * 0.5
    }
    r.y += MAP_CHIP_H * 0.5 if p.mapx % 2 == 0
    return r

  relativeRotation: (rotation,p1,p2) ->
    r = Math.radToDeg(Math.atan2 p2.y - p1.y, p2.x - p1.x) - rotation
    if r > 180
      r -= 360
    else if r < -180
      r += 360
    return r

  lineRoute: (p1,p2) ->
    ret = [{
      mapx: p1.mapx
      mapy: p1.mapy
    }]
    dx = p2.mapx - p1.mapx
    dy = p2.mapy - p1.mapy
    hx = if dx < 0 then -1 else 1
    hy = if dy < 0 then -1 else 1
    ax = Math.abs dx
    ay = Math.abs dy
    if ax < ay
      sx = if ay is 0 then hx else dx / ay
      sy = if dy < 0 then -1 else 1
      for y in [1 .. ay]
        p = {
          mapx: p1.mapx + sx * y
          mapy: p1.mapy + sy * y
        }
        p.mapx = Math.round(p.mapx)
        while @distance(ret[ret.length - 1],p) > 1
          ret.push {
            mapx: p.mapx - hx
            mapy: p.mapy
          }
        ret.push p
    else
      sx = if dx < 0 then -1 else 1
      sy = if ax is 0 then hy else dy / ax
      for x in [1 .. ax]
        p = {
          mapx: p1.mapx + sx * x
          mapy: p1.mapy + sy * x
        }
        p.mapy -= 0.5 if p.mapx % 2 == 0
        p.mapy = Math.round(p.mapy)
        while @distance(ret[ret.length - 1],p) > 1
          ret.push {
            mapx: p.mapx
            mapy: p.mapy - hy
          }
        ret.push p
    return ret
    

  ###* 座標方向確認。
  * キャラクターの向いている方向を考慮し、指定された座標が、キャラクターからみてどの方向にあるか確認する。
  * @param {Object}   param
  * @param {number}   param.rotation キャラクターの向いている方向
  * @param {number}   param.source   キャラクターの座標(x,y)
  * @param {number}   param.target   ターゲット座標(x,y)
  * @param {number}   param.start    確認する開始角度 -180 ～ 180
  * @param {number}   param.end      確認する終了角度 -180 ～ 180
  * @param {boolean}  param.anticlockwise
  * @param {Function} param.callback チェック結果をもらう関数
  ###
  checkDirectionRange: (param) ->
    {
      rotation
      source
      target
      callback
    } = param
    {
      start
      end
      anticlockwise
    } = param.range
    rotation = DIRECTIONS[source.direction].rotation unless rotation?
    r = nz.utils.relativeRotation(rotation,source,target)
    r1 = if anticlockwise then end   else start
    r2 = if anticlockwise then start else end
    res = false
    if r1 < r2
      res = r1 <= r and r <= r2
    else
      res = r1 <= r or  r <= r2
    if callback?
      unless res
        ra = r1 if r1 > r
        ra = r2 if r  > r2
      else
        ra = r
      callback(res,ra)
    return res

nz.utils = new nz.Utils()
