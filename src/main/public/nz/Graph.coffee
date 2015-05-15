###*
* @file Graph.coffee
* A*用グラフクラス
###

###* nineteen namespace.
* @namespace nz
###

# node.js と ブラウザでの this.nz を同じインスタンスにする
_g = window ? global
nz = _g.nz = _g.nz ? {}
_g = undefined

_NEIGHBORS = [
  [
    [[ 0,-1, 0],[ 0, 0, 5],[ 0, 0, 1],[ 0, 1, 0]]
    [[ 1, 0, 1],[ 0, 0, 0],[ 0, 0, 2],[-1, 1, 1]]
    [[ 1, 1, 2],[ 0, 0, 1],[ 0, 0, 3],[-1, 0, 2]]
    [[ 0, 1, 3],[ 0, 0, 2],[ 0, 0, 4],[ 0,-1, 3]]
    [[-1, 1, 4],[ 0, 0, 3],[ 0, 0, 5],[ 1, 0, 4]]
    [[-1, 0, 5],[ 0, 0, 4],[ 0, 0, 0],[ 1, 1, 5]]
  ]
  [
    [[ 0,-1, 0],[ 0, 0, 5],[ 0, 0, 1],[ 0, 1, 0]]
    [[ 1,-1, 1],[ 0, 0, 0],[ 0, 0, 2],[-1, 0, 1]]
    [[ 1, 0, 2],[ 0, 0, 1],[ 0, 0, 3],[-1,-1, 2]]
    [[ 0, 1, 3],[ 0, 0, 2],[ 0, 0, 4],[ 0,-1, 3]]
    [[-1, 0, 4],[ 0, 0, 3],[ 0, 0, 5],[ 1,-1, 4]]
    [[-1,-1, 5],[ 0, 0, 4],[ 0, 0, 0],[ 1, 0, 5]]
  ]
]

class nz.Graph

  ###* コンストラクタ.
  * @classdesc A*用グラフクラス
  * @constructor nz.Graph
  ###
  constructor: (param = {}) ->
    {
      mapdata
      chipdata
    } = param
    @nodes = []
    @grid = []
    @grid[x] = [] for x in [0...mapdata.width]
    for y in [0...mapdata.height]
      for x in [0...mapdata.width]
        unless y == mapdata.height - 1 and x % 2 == 0
          chipid = mapdata.data[y][x]
          node = new nz.GridNode(x,y,chipdata[chipid])
          @grid[x][y] = node
          @nodes.push(node)
    @clear()

  ###* クリア
  * @memberof nz.Graph#
  * @method clear
  ###
  clear: ->
    @cleanWrap()
    for node in @nodes
      node.clean()
    return

  ###* ダーティノードの削除
  * @memberof nz.Graph#
  * @method cleanDirty
  ###
  cleanDirty: ->
    return

  ###* ダーティノードのマーク
  * @memberof nz.Graph#
  * @method markDirty
  * @param {Object} node
  ###
  markDirty: (node) ->
    return

  ###* ラップクラスの削除
  * @memberof nz.Graph#
  * @method cleanWrap
  ###
  cleanWrap: ->
    @wrapNodes = {}
    return

  ###* ラップクラスの取得
  * @memberof nz.Graph#
  * @method getWrap
  ###
  getWrap: (x,y,d) ->
    key = "#{x}-#{y}"
    if @wrapNodes[key]?
      return @wrapNodes[key]
    unless d?
      unless @wrapNodes[key]?
        @wrapNodes[key] = new nz.GridNodeWrap(@grid[x][y])
        astar.cleanNode(@wrapNodes[key])
    else
      key = "#{x}-#{y}-#{d}"
      unless @wrapNodes[key]?
        @wrapNodes[key] = new nz.GridNodeWrap(@grid[x][y],d)
        astar.cleanNode(@wrapNodes[key])
    @wrapNodes[key]


  neighbors: (wrap) ->
    ret = []
    for [x,y,d] in _NEIGHBORS[wrap.mapx % 2][wrap.direction]
      x += wrap.mapx
      y += wrap.mapy
      if @grid[x]?[y]?
        ret.push @getWrap(x,y,d)
    return ret

  toString: ->
    graphString = []
    for nodes in @grid
      rowDebug = []
      for node in nodes
        rowDebug.push(node.weight)
      graphString.push(rowDebug.join(" "))
    return graphString.join("\n")

  searchRoute: (sd,sx,sy,ex,ey,op={}) ->
    route = []
    start = @getWrap sx,sy,sd
    end   = @getWrap ex,ey
    # 壁じゃなかったら探索
    if (not end.isWall()) or op.closest

      unless op.closest?
        op.closest = false
      unless op.heuristic?
        op.heuristic = nz.Graph.heuristic
      unless op.grid?
        op.grid = []

      for g in op.grid
        @grid[g.mapx][g.mapy].options = g.options
      if op.graph?
        @options = op.graph

      result = astar.search(@, start, end, op)
      pd = sd
      for wrap in result
        route.push {
          mapx: wrap.mapx
          mapy: wrap.mapy
          cost: wrap.g
          back: wrap.back
          direction: if wrap.direction < 0 then pd else wrap.direction
        }
        pd = wrap.direction
      for g in op.grid
        @grid[g.mapx][g.mapy].options = undefined
      @options = undefined
    @cleanWrap()
    return route

nz.Graph.heuristic = (wrap1,wrap2) ->
  hx = Math.abs(wrap1.mapx - wrap2.mapx)
  hy = Math.abs(wrap1.mapy - wrap2.mapy)
  #hr = Math.floor(hx / 2)
  hr = Math.ceil(hx / 2)
  direction = wrap1.node.calcDirectionTo(wrap2)
  hd = nz.Graph.directionCost(wrap1.direction,direction)
  if hy == hr
    hy = 0
  else if hy < hr
    if hy != 0
      hy = 1
      if hd == 1
        hd = 0
  else
    hy -= hr
  #console.log "#{wrap1.mapx} #{wrap1.mapy} #{wrap2.mapx} #{wrap2.mapy} #{hx} #{hy} #{hd} #{direction}"
  hx + hy + hd

###* 対象の方向
* @param {Object} c1 元
* @param {Object} c2 対象
###
nz.Graph.direction = (c1,c2) ->
  dis = nz.Graph.distance c1,c2
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

###* 距離
* @param {Object} c1 元
* @param {Object} c2 対象
###
nz.Graph.distance = (c1,c2) ->
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

###* 方向転換にかかるコストを計算
* @param {number} direction1 方向1
* @param {number} direction2 方向2
###
nz.Graph.directionCost = (direction1,direction2) ->
  Math.abs(3 - Math.abs((direction2 - direction1 - 3) % 6))

# mapx = _FRONT_POS[mapx % 2][direction][0]
# mapy = _FRONT_POS[mapx % 2][direction][1]
_FRONT_POS = [
  [[ 0,-1],[ 1, 0],[ 1, 1],[ 0, 1],[-1, 1],[-1, 0]]
  [[ 0,-1],[ 1,-1],[ 1, 0],[ 0, 1],[-1, 0],[-1,-1]]
]

###* 向いている目の前の座標を取得する
* @param {Object} p           パラメータ
* @param {number} p.mapx      X座標
* @param {number} p.mapy      Y座標
* @param {number} p.direction 方向
* @return {Object} 目の前の座標
###
nz.Graph.frontPosition = (p) ->
  d = (p.direction + 6) % 6
  t = p.mapx % 2
  return {
    mapx:      p.mapx + _FRONT_POS[t][d][0]
    mapy:      p.mapy + _FRONT_POS[t][d][1]
    direction: d
  }

###* 向いている方向に対する後ろの座標を取得する
* @param {Object} p           パラメータ
* @param {number} p.mapx      X座標
* @param {number} p.mapy      Y座標
* @param {number} p.direction 方向
* @return {Object} 後ろの座標
###
nz.Graph.backPosition = (p) ->
  r = nz.Graph.frontPosition {
    mapx: p.mapx
    mapy: p.mapy
    direction: p.direction + 3
  }
  r.direction = p.direction
  return r

###* ヘックス状のライン座標を取得する
* @param {Object} p           パラメータ
* @param {number} p.mapx      X座標
* @param {number} p.mapy      Y座標
* @param {number} p.direction 方向
* @param {number} p.distance  距離
* @return {Array<Object>} 座標配列
###
nz.Graph.hexLine = (p) ->
  r = []
  for n in [0 ... p.distance]
    r.push (p = @frontPosition(p))
  return r

###* 方向に対する座標エリアを取得する。
* 時計まわりに３０度のエリアを探す。
* @param {Object} p           パラメータ
* @param {number} p.mapx      X座標
* @param {number} p.mapy      Y座標
* @param {number} p.direction 方向
* @param {number} p.distance  距離
* @return {Array<Object>} 座標配列
###
nz.Graph.frontArea = (p) ->
  r = []
  for a,i in @hexLine(p)
    r.push a
    a.direction += 2
    a.distance = i + 1
    Array.prototype.push.apply r, @hexLine(a)
  return r
