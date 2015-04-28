###*
* @file Graph.coffee
* A*用グラフクラス
###

# node.js と ブラウザでの this.nz を同じインスタンスにする
_g = window ? global
nz = _g.nz = _g.nz ? {}
_g = undefined

class nz.Graph
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

  clear: ->
    for node in @nodes
      node.clean()
      astar.cleanNode(node)
    @dirtyNodes = []

  cleanDirty: ->
    for node in @dirtyNodes
      node.clean()
      astar.cleanNode(node)
    @dirtyNodes = []

  markDirty: (node) ->
    if @dirtyNodes.indexOf(node) < 0
      @dirtyNodes.push node

  _addWrap: (ret,x,y,d) ->
    ret.push(new nz.GridNodeWrap(@grid[x][y],d)) if(@grid[x]?[y]?)

  neighbors: (wrap) ->
    ret = []
    x = wrap.mapx
    y = wrap.mapy

    if x % 2 == 0
      switch wrap.direction
        when 0
          @_addWrap ret,x,y-1,wrap.direction
          @_addWrap ret,x,y,5
          @_addWrap ret,x,y,1
        when 1
          @_addWrap ret,x+1,y,wrap.direction
          @_addWrap ret,x,y,0
          @_addWrap ret,x,y,2
        when 2
          @_addWrap ret,x+1,y+1,wrap.direction
          @_addWrap ret,x,y,1
          @_addWrap ret,x,y,3
        when 3
          @_addWrap ret,x,y+1,wrap.direction
          @_addWrap ret,x,y,2
          @_addWrap ret,x,y,4
        when 4
          @_addWrap ret,x-1,y+1,wrap.direction
          @_addWrap ret,x,y,3
          @_addWrap ret,x,y,5
        when 5
          @_addWrap ret,x-1,y,wrap.direction
          @_addWrap ret,x,y,4
          @_addWrap ret,x,y,0
    else
      switch wrap.direction
        when 0
          @_addWrap ret,x,y-1,wrap.direction
          @_addWrap ret,x,y,5
          @_addWrap ret,x,y,1
        when 1
          @_addWrap ret,x+1,y-1,wrap.direction
          @_addWrap ret,x,y,0
          @_addWrap ret,x,y,2
        when 2
          @_addWrap ret,x+1,y,wrap.direction
          @_addWrap ret,x,y,1
          @_addWrap ret,x,y,3
        when 3
          @_addWrap ret,x,y+1,wrap.direction
          @_addWrap ret,x,y,2
          @_addWrap ret,x,y,4
        when 4
          @_addWrap ret,x-1,y,wrap.direction
          @_addWrap ret,x,y,3
          @_addWrap ret,x,y,5
        when 5
          @_addWrap ret,x-1,y-1,wrap.direction
          @_addWrap ret,x,y,4
          @_addWrap ret,x,y,0

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

  searchRoute: (sd,sx,sy,ex,ey,op={closest:false}) ->
    route = []
    start = new nz.GridNodeWrap(@grid[sx][sy],sd)
    end   = new nz.GridNodeWrap(@grid[ex][ey])
    # 壁じゃなかったら探索
    if (not end.isWall()) or op.closest
      op.heuristic = nz.Graph.heuristic unless op.heuristic?

      if op.grid?
        for g in op.grid
          @grid[g.mapx][g.mapy].options = g.options
      if op.graph?
        @options = op.graph

      result = astar.search(@, start, end, op)
      for node in result
        route.push {
          mapx: node.mapx
          mapy: node.mapy
          direction: node.direction
          cost: node.g
        }
      if op.grid?
        for g in op.grid
          @grid[g.mapx][g.mapy].options = undefined
      @options = undefined
    return route

nz.Graph.heuristic = (node1,node2) ->
  hx = Math.abs(node1.mapx - node2.mapx)
  hy = Math.abs(node1.mapy - node2.mapy)
  #hr = Math.floor(hx / 2)
  hr = Math.ceil(hx / 2)
  direction = node1.calcDirectionTo(node2)
  hd = node1.getDirectionCost(direction)
  if hy == hr
    hy = 0
  else if hy < hr
    if hy != 0
      hy = 1
      if hd == 1
        hd = 0
  else
    hy -= hr
  #console.log "#{hx} #{hy} #{hd} #{direction}"
  hx + hy + hd
