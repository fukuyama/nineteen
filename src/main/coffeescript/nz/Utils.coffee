# Utils.coffee

# node.js と ブラウザでの this.nz を同じインスタンスにする
_g = window ? global
nz = _g.nz = _g.nz ? {}
_g = undefined

MAP_CHIP_W = nz.system.map.chip.width
MAP_CHIP_H = nz.system.map.chip.height
DIRECTIONS = nz.system.character.directions

class nz.Utils

  ###* オブジェクトマージ
  * @param {Object} r 受け側オブジェクト
  * @param {Object} o マージオブジェクト
  ###
  marge: (r,o) ->
    for k,v of o
      if typeof v is 'object'
        if v instanceof Array
          r[k] = [].concat v
        else
          r[k] = {} unless r[k]?
          @marge r[k], v
      else
        r[k] = v
    return r


  ###* 経路探索
  * @param {nz.Graph} graph  グラフ（マップ情報）
  * @param {Object}   source 開始位置のキャラクター({mapx,mapy,direction})
  * @param {Object}   target 終了位置のキャラクターか位置情報({mapx,mapy})
  * @param {Array}    characters 配列(Character)
  * @param {Object}   [options] オプション
  * @param {boolean}  [options.closest] 到達できない場合に近くまで探索する場合 true
  * @param {Object}   [options.grid] グリッドオプション
  * @return {Array}   ルート情報
  ###
  searchRoute: (graph, source, target, characters, options = {})->
    unless options.grid?
      options.grid = []
    unless options.graph?
      options.graph = {
        cost: source.ap
      }
    unless options.closest?
      options.closest = true
    # FIXME:キャラクターとは重なれない(途中のキャラクターは重なっても良いような…それともZOCみたいにする？)
    for c in characters when c.isAlive() and (source.mapx != c.mapx or source.mapy != c.mapy)
      options.grid.push {
        mapx: c.mapx
        mapy: c.mapy
        options: {
          isWall: true
        }
      }

    {direction,mapx,mapy} = source
    return graph.searchRoute(direction, mapx, mapy, target.mapx, target.mapy, options)

  ###* マップ座標をスクリーン座標へ変換
  * @param {Object} p {mapx,mapy}
  * @return {Object}  {x,y}
  ###
  mapxy2screenxy: (p) ->
    if arguments.length == 2
      p = {
        mapx: arguments[0]
        mapy: arguments[1]
      }
    # origin があるから、0.5 ずらす
    r = {
      x: p.mapx * MAP_CHIP_W + MAP_CHIP_W * 0.5
      y: p.mapy * MAP_CHIP_H + MAP_CHIP_H * 0.5
    }
    r.y += MAP_CHIP_H * 0.5 if p.mapx % 2 == 0
    return r

  ###* スクリーン座標をマップ座標へ変換
  * @param {Object} p {x,y}
  * @return {Object}  {mapx,mapy}
  ###
  screenxy2mapxy: (p) ->
    if arguments.length == 2
      p = {
        x: arguments[0]
        y: arguments[1]
      }
    mapx = Math.floor p.x / MAP_CHIP_W
    if mapx % 2 == 0
      mapy = Math.floor (p.y - MAP_CHIP_H * 0.5) / MAP_CHIP_H
    else
      mapy = Math.floor p.y / MAP_CHIP_H
    mapx = 0 if mapx < 0
    mapy = 0 if mapy < 0
    return {
      mapx: mapx
      mapy: mapy
    }

  normalizRotation: (r) ->
    r -= 360 while r > 180
    r += 360 while r < -180
    return r

  relativeRotation: (rotation,p1,p2) ->
    r = 0
    if p2?
      r = Math.radToDeg(Math.atan2 p2.y - p1.y, p2.x - p1.x)
    else
      r = p1 % 360
    return @normalizRotation r - rotation

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
        while nz.Graph.distance(ret[ret.length - 1],p) > 1
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
        while nz.Graph.distance(ret[ret.length - 1],p) > 1
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
  * @param {boolean}  param.anticlockwise range 方向(true 反時計回り)
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
