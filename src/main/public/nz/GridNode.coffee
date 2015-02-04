###*
* @file GridNode.coffee
* A*用ノードクラス
###

# node.js と ブラウザでの this.nz を同じインスタンスにする
_g = window ? global ? @
nz = _g.nz = _g.nz ? {}
_g = undefined


class nz.GridNode

  constructor: (x, y, chipdata) ->
    @x      = x
    @y      = y
    @weight = chipdata.weight

  toString: ->
    return "[#{@x},#{@y}]"

  getCost: ->
    return @weight

  isWall: ->
    return @weight == 0
