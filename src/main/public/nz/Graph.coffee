###*
* @file Graph.coffee
* A*用グラフクラス
###

# node.js と ブラウザでの this.nz を同じインスタンスにする
_g = window ? global ? @
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
    for xnodes in mapdata
      @grid[x] = []
      for node in xnodes
        @grid[x][y] = new nz.GridNode(x,y,chipdata[node])
        @nodes.push(node)
    @init()

  init: ->
    @dirtyNodes = []
    astar.cleanNode(node) for node in @nodes

  cleanDirty: ->
    astar.cleanNode(node) for node in @dirtyNodes
    @dirtyNodes = []

  markDirty: (node) ->
    @dirtyNodes.push node

  neighbors: (node) ->
    ret = []
    x = node.x
    y = node.y
    grid = @grid

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
