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

  cleanDirty: ->

  markDirty: (node) ->

  neighbors: (node) ->
    ret = []
    x = node.x
    y = node.y

    if x % 2 == 0
      ret.push(@grid[x  ][y-1]) if(@grid[x  ]?[y-1]?)
      ret.push(@grid[x  ][y+1]) if(@grid[x  ]?[y+1]?)
      ret.push(@grid[x-1][y  ]) if(@grid[x-1]?[y  ]?)
      ret.push(@grid[x-1][y+1]) if(@grid[x-1]?[y+1]?)
      ret.push(@grid[x+1][y  ]) if(@grid[x+1]?[y  ]?)
      ret.push(@grid[x+1][y+1]) if(@grid[x+1]?[y+1]?)
    else
      ret.push(@grid[x  ][y-1]) if(@grid[x  ]?[y-1]?)
      ret.push(@grid[x  ][y+1]) if(@grid[x  ]?[y+1]?)
      ret.push(@grid[x-1][y  ]) if(@grid[x-1]?[y  ]?)
      ret.push(@grid[x-1][y-1]) if(@grid[x-1]?[y-1]?)
      ret.push(@grid[x+1][y  ]) if(@grid[x+1]?[y  ]?)
      ret.push(@grid[x+1][y-1]) if(@grid[x+1]?[y-1]?)

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

  searchRoute: (sd,sx,sy,ex,ey) ->
    route = []
    start = @grid[sx][sy]
    end   = @grid[ex][ey]

    start.direction = sd
    result = astar.search(@, start, end, {heuristic: nz.Graph.heuristic})
    for node in result
      route.push {
        x: node.x
        y: node.y
        direction: node.direction
      }
    @clear()
    return route

nz.Graph.heuristic = (node1,node2) ->
  hx = Math.abs(node1.x - node2.x)
  hy = Math.abs(node1.y - node2.y)
  hr = Math.floor(hx / 2)
  if hy == hr
    hy = 0
  else if hy < hr
    hy = 1 if hy != 0
  else
    hy -= hr
  hd = 0
  if node1.direction != 0
    direction = node1.calcDirectionTo(node2)
    hd = node1.getDirectionCost(direction)
  # console.log "#{hx} #{hy} #{hd} #{direction}"
  hx + hy + hd
