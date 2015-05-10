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

  ###* クリア ###
  clear: ->
    @cleanWrap()
    for node in @nodes
      node.clean()
      # astar.cleanNode(node)
    #@dirtyNodes = []
    return

  ###* ダーティノードの削除 ###
  cleanDirty: ->
    #for node in @dirtyNodes
    #  node.clean()
    #  astar.cleanNode(node)
    #@dirtyNodes = []
    return

  ###* ダーティノードのマーク ###
  markDirty: (node) ->
    #if @dirtyNodes.indexOf(node) < 0
    #  @dirtyNodes.push node
    return

  ###* ラップクラスの削除 ###
  cleanWrap: ->
    @wrapNodes = {}
    return

  ###* ラップクラスの作成
  * @memberof nz.ai.Param#
  * @method findNearTarget
  ###
  createWrap: (x,y,d) ->
    key = "#{x}-#{y}"
    if @wrapNodes[key]?
      return @wrapNodes[key]
    unless d?
      key = "#{x}-#{y}"
      unless @wrapNodes[key]?
        @wrapNodes[key] = new nz.GridNodeWrap(@grid[x][y])
        astar.cleanNode(@wrapNodes[key])
    else
      key = "#{x}-#{y}-#{d}"
      unless @wrapNodes[key]?
        @wrapNodes[key] = new nz.GridNodeWrap(@grid[x][y],d)
        astar.cleanNode(@wrapNodes[key])
    @wrapNodes[key]


  _addWrap: (ret,x,y,d) ->
    if(@grid[x]?[y]?)
      ret.push @createWrap(x,y,d)
    return

  neighbors: (wrap) ->
    ret = []
    x = wrap.mapx
    y = wrap.mapy
    # console.log "neighbors #{x},#{y},#{wrap.direction}"

    if x % 2 == 0
      switch wrap.direction
        when 0
          @_addWrap ret,x,y-1,wrap.direction
          @_addWrap ret,x,y,5
          @_addWrap ret,x,y,1
          @_addWrap ret,x,y+1,wrap.direction
        when 1
          @_addWrap ret,x+1,y,wrap.direction
          @_addWrap ret,x,y,0
          @_addWrap ret,x,y,2
          @_addWrap ret,x-1,y+1,wrap.direction
        when 2
          @_addWrap ret,x+1,y+1,wrap.direction
          @_addWrap ret,x,y,1
          @_addWrap ret,x,y,3
          @_addWrap ret,x-1,y,wrap.direction
        when 3
          @_addWrap ret,x,y+1,wrap.direction
          @_addWrap ret,x,y,2
          @_addWrap ret,x,y,4
          @_addWrap ret,x,y-1,wrap.direction
        when 4
          @_addWrap ret,x-1,y+1,wrap.direction
          @_addWrap ret,x,y,3
          @_addWrap ret,x,y,5
          @_addWrap ret,x+1,y,wrap.direction
        when 5
          @_addWrap ret,x-1,y,wrap.direction
          @_addWrap ret,x,y,4
          @_addWrap ret,x,y,0
          @_addWrap ret,x+1,y+1,wrap.direction
    else
      switch wrap.direction
        when 0
          @_addWrap ret,x,y-1,wrap.direction
          @_addWrap ret,x,y,5
          @_addWrap ret,x,y,1
          @_addWrap ret,x,y+1,wrap.direction
        when 1
          @_addWrap ret,x+1,y-1,wrap.direction
          @_addWrap ret,x,y,0
          @_addWrap ret,x,y,2
          @_addWrap ret,x-1,y,wrap.direction
        when 2
          @_addWrap ret,x+1,y,wrap.direction
          @_addWrap ret,x,y,1
          @_addWrap ret,x,y,3
          @_addWrap ret,x-1,y-1,wrap.direction
        when 3
          @_addWrap ret,x,y+1,wrap.direction
          @_addWrap ret,x,y,2
          @_addWrap ret,x,y,4
          @_addWrap ret,x,y-1,wrap.direction
        when 4
          @_addWrap ret,x-1,y,wrap.direction
          @_addWrap ret,x,y,3
          @_addWrap ret,x,y,5
          @_addWrap ret,x+1,y-1,wrap.direction
        when 5
          @_addWrap ret,x-1,y-1,wrap.direction
          @_addWrap ret,x,y,4
          @_addWrap ret,x,y,0
          @_addWrap ret,x+1,y,wrap.direction

    # nz なノードを返す（６こ）
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
    start = @createWrap sx,sy,sd
    end   = @createWrap ex,ey
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

###* 方向に対する後ろの座標を取得する
* @param {number|Object} mapx X座標
* @param {number}        mapy Y座標
* @param {number}        direction 方向
###
nz.Graph.backPosition = (mapx,mapy,direction) ->
  if typeof mapx is 'object'
    {
      mapx
      mapy
      direction
    } = mapx
  if mapx % 2 == 0
    switch direction
      when 0
        mapy += 1
      when 1
        mapx -= 1
        mapy += 1
      when 2
        mapx -= 1
      when 3
        mapy -= 1
      when 4
        mapx += 1
      when 5
        mapx += 1
        mapy += 1
  else
    switch direction
      when 0
        mapy += 1
      when 1
        mapx -= 1
      when 2
        mapx -= 1
        mapy -= 1
      when 3
        mapy -= 1
      when 4
        mapx += 1
        mapy -= 1
      when 5
        mapx += 1
  return {
    mapx:      mapx
    mapy:      mapy
    direction: direction
  }
