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
        chipid = mapdata.data[y][x]
        node = new nz.GridNode(x,y,chipdata[chipid])
        @grid[x][y] = node
        @nodes.push(node)
    @init()

  init: ->
    @dirtyNodes = []
    @cleanNode(node) for node in @nodes

  cleanDirty: ->
    @cleanNode(node) for node in @dirtyNodes
    @dirtyNodes = []

  cleanNode: (node) ->
    astar.cleanNode(node)
    node.clean()

  markDirty: (node) ->
    @dirtyNodes.push node

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

nz.Graph.heuristic = (node1,node2) ->
  hx = Math.abs(node1.x - node2.x)
  hy = Math.abs(node1.y - node2.y) - Math.floor(hx / 2)
  hd = 0
  if node1.direction != 0
    direction = node1.calcDirectionTo(node2)
    hd = node1.getDirectionCost(direction)
  # console.log "#{hx} #{hy} #{hd} #{direction}"
  hx + hy + hd